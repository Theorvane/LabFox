import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:gitlab_models/gitlab_models.dart';

final _header = RegExp(r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@');

/// Indexes literal members once so range end eligibility is constant time.
class ReviewDiffRange {
  ReviewDiffRange(FileDiff file) {
    final hash = sha1.convert(utf8.encode(file.newPath)).toString();
    final codes = <String, int>{};
    final complete = <bool>[], gaps = <bool>[];
    var previousOld = -1, previousNew = -1;
    for (final hunk in file.hunks) {
      var old = hunk.oldStart, newer = hunk.newStart;
      gaps.add(previousOld != old || previousNew != newer);
      for (final line in hunk.lines) {
        final code = '${hash}_${old}_$newer';
        _indices[line] = _rows.length;
        _rows.add((line: line, hunk: complete.length, code: code));
        codes.update(code, (count) => count + 1, ifAbsent: () => 1);
        _endpoints[line] = DiffNoteRangeEndpoint(
          lineCode: code,
          type: line.type == DiffLineType.added ? 'new' : 'old',
          oldLine: line.oldLine,
          newLine: line.newLine,
        );
        if (line.oldLine != null) old++;
        if (line.newLine != null) newer++;
      }
      final header = _header.firstMatch(hunk.header);
      complete.add(
        header != null &&
            old - hunk.oldStart == int.tryParse(header.group(2) ?? '1') &&
            newer - hunk.newStart == int.tryParse(header.group(4) ?? '1'),
      );
      previousOld = old;
      previousNew = newer;
    }
    for (var i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      _badRows.add(_badRows.last + (codes[row.code] != 1 ? 1 : 0));
    }
    for (var h = 0; h < complete.length; h++) {
      _badHunks.add(_badHunks.last + (complete[h] ? 0 : 1));
      _gaps.add(_gaps.last + (gaps[h] ? 1 : 0));
    }
  }

  final _rows = <({DiffLine line, int hunk, String code})>[];
  final _indices = Map<DiffLine, int>.identity();
  final _endpoints = Map<DiffLine, DiffNoteRangeEndpoint>.identity();
  final _badRows = <int>[0], _badHunks = <int>[0], _gaps = <int>[0];

  DiffNoteLineRange? between(DiffLine start, DiffLine end) {
    final first = _indices[start], last = _indices[end];
    if (first == null || last == null || first >= last) return null;
    final firstHunk = _rows[first].hunk, lastHunk = _rows[last].hunk;
    if (_badRows[last + 1] != _badRows[first] ||
        _badHunks[lastHunk + 1] != _badHunks[firstHunk] ||
        _gaps[lastHunk + 1] != _gaps[firstHunk + 1]) {
      return null;
    }
    return DiffNoteLineRange(start: _endpoints[start], end: _endpoints[end]);
  }

  /// Read matching omits optional display coordinates, while sides/codes are exact.
  List<DiffLine> matching(DiffNoteLineRange range) {
    DiffLine? member(DiffNoteRangeEndpoint? endpoint) {
      if (endpoint == null) return null;
      for (final entry in _endpoints.entries) {
        final p = entry.value;
        if (p.lineCode == endpoint.lineCode &&
            p.type == endpoint.type &&
            (endpoint.oldLine == null || endpoint.oldLine == p.oldLine) &&
            (endpoint.newLine == null || endpoint.newLine == p.newLine)) {
          return entry.key;
        }
      }
      return null;
    }

    final start = member(range.start), end = member(range.end);
    if (start == null || end == null || between(start, end) == null) {
      return const [];
    }
    final sameSide = range.start!.type == range.end!.type;
    return List.unmodifiable([
      for (var i = _indices[start]!; i <= _indices[end]!; i++)
        if (!sameSide ||
            (range.start!.type == 'old'
                ? _rows[i].line.oldLine != null
                : _rows[i].line.newLine != null))
          _rows[i].line,
    ]);
  }
}
