import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:gitlab_models/gitlab_models.dart';

final _lineCode = RegExp(r'^[0-9a-f]{40}_(0|[1-9][0-9]*)_(0|[1-9][0-9]*)$');
final _header = RegExp(r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@');

/// Reject incomplete endpoints before fetching an original snapshot.
bool supportsOriginalDiffRange(DiffNoteLineRange range) =>
    _validEndpoint(range.start) && _validEndpoint(range.end);

bool _validEndpoint(DiffNoteRangeEndpoint? endpoint) {
  if (endpoint == null) return false;
  final code = _lineCode.firstMatch(endpoint.lineCode ?? '');
  if (code == null) return false;
  final old = endpoint.oldLine, newer = endpoint.newLine;
  final codeOld = int.tryParse(code.group(1)!);
  final codeNew = int.tryParse(code.group(2)!);
  if (codeOld == null || codeNew == null) return false;
  return (endpoint.type == 'old'
          ? codeOld > 0
          : endpoint.type == 'new' && codeNew > 0) &&
      (old == null || old > 0 && old == codeOld) &&
      (newer == null || newer > 0 && newer == codeNew);
}

typedef _Row = ({DiffLine line, int hunk, String code});

/// Matches literal line codes and visible side coordinates in an original file.
/// Opposite counters in added/removed line codes are not visible coordinates.
/// Only complete, contiguous available hunks can represent a selected span.
List<DiffLine>? originalDiffRange(FileDiff file, DiffNoteLineRange range) {
  if (!supportsOriginalDiffRange(range)) return null;
  final hash = sha1.convert(utf8.encode(file.newPath)).toString();
  final rows = <_Row>[];
  final complete = <bool>[];
  final ends = <(int, int)>[];
  for (var h = 0; h < file.hunks.length; h++) {
    final hunk = file.hunks[h];
    var old = hunk.oldStart, newer = hunk.newStart;
    for (final line in hunk.lines) {
      rows.add((line: line, hunk: h, code: '${hash}_${old}_$newer'));
      if (line.oldLine != null) old++;
      if (line.newLine != null) newer++;
    }
    final header = _header.firstMatch(hunk.header);
    complete.add(
      header != null &&
          old - hunk.oldStart == int.tryParse(header.group(2) ?? '1') &&
          newer - hunk.newStart == int.tryParse(header.group(4) ?? '1'),
    );
    ends.add((old, newer));
  }
  bool matches(_Row row, DiffNoteRangeEndpoint endpoint) =>
      row.code == endpoint.lineCode &&
      (endpoint.oldLine == null || row.line.oldLine == endpoint.oldLine) &&
      (endpoint.newLine == null || row.line.newLine == endpoint.newLine) &&
      (endpoint.type == 'old'
          ? row.line.oldLine != null
          : row.line.newLine != null);
  final starts = <int>[], finishes = <int>[];
  final counts = <String, int>{};
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i];
    counts.update(row.code, (v) => v + 1, ifAbsent: () => 1);
    if (matches(row, range.start!)) starts.add(i);
    if (matches(row, range.end!)) finishes.add(i);
  }
  if (starts.length != 1 ||
      finishes.length != 1 ||
      starts.single > finishes.single) {
    return null;
  }
  final span = rows.sublist(starts.single, finishes.single + 1);
  if (span.any((row) => counts[row.code] != 1)) return null;
  final first = span.first.hunk, last = span.last.hunk;
  for (var h = first; h <= last; h++) {
    if (!complete[h]) return null;
    if (h > first &&
        ends[h - 1] != (file.hunks[h].oldStart, file.hunks[h].newStart)) {
      return null;
    }
  }
  final sameSide = range.start!.type == range.end!.type;
  return List.unmodifiable([
    for (final row in span)
      if (!sameSide ||
          (range.start!.type == 'old'
              ? row.line.oldLine != null
              : row.line.newLine != null))
        row.line,
  ]);
}
