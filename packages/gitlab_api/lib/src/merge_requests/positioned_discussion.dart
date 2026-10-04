import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:gitlab_models/gitlab_models.dart';

final _lineCode = RegExp(r'^[0-9a-f]{40}_(0|[1-9][0-9]*)_(0|[1-9][0-9]*)$');

(int, int)? _counters(DiffNoteRangeEndpoint? endpoint, String hash) {
  if (endpoint == null || !(endpoint.lineCode ?? '').startsWith('${hash}_')) {
    return null;
  }
  final match = _lineCode.firstMatch(endpoint.lineCode ?? '');
  if (match == null) return null;
  final old = int.tryParse(match.group(1)!);
  final newer = int.tryParse(match.group(2)!);
  if (old == null ||
      newer == null ||
      (endpoint.type == 'old'
          ? old < 1
          : endpoint.type != 'new' || newer < 1) ||
      (endpoint.oldLine != null &&
          (endpoint.oldLine! < 1 || endpoint.oldLine != old)) ||
      (endpoint.newLine != null &&
          (endpoint.newLine! < 1 || endpoint.newLine != newer))) {
    return null;
  }
  return (old, newer);
}

/// Restricts creation to complete original text anchors with supported ranges.
/// Path and SHA guards precede range hashing so incomplete positions are safe.
bool validTextDiscussionPosition(DiffNotePosition position) =>
    position.positionType == 'text' &&
    [
      position.baseSha,
      position.startSha,
      position.headSha,
    ].every((value) => value != null && value.trim().isNotEmpty) &&
    [
      position.oldPath,
      position.newPath,
    ].every((value) => value != null && value.isNotEmpty) &&
    (position.oldLine != null || position.newLine != null) &&
    (position.oldLine == null || position.oldLine! > 0) &&
    (position.newLine == null || position.newLine! > 0) &&
    position.width == null &&
    position.height == null &&
    position.x == null &&
    position.y == null &&
    validMultilinePosition(position);

/// Checks the structural original range; callers still verify literal diff membership.
bool validMultilinePosition(DiffNotePosition position) {
  final range = position.lineRange;
  if (range == null) return true;
  final hash = sha1.convert(utf8.encode(position.newPath!)).toString();
  final start = _counters(range.start, hash), end = _counters(range.end, hash);
  if (start == null || end == null || start.$1 > end.$1 || start.$2 > end.$2) {
    return false;
  }
  final endpoint = range.end!;
  return (endpoint.type == 'old'
          ? position.oldLine == end.$1
          : position.newLine == end.$2) &&
      (position.oldLine == null || position.oldLine == end.$1) &&
      (position.newLine == null || position.newLine == end.$2) &&
      (endpoint.oldLine == null || endpoint.oldLine == position.oldLine) &&
      (endpoint.newLine == null || endpoint.newLine == position.newLine);
}

/// Display coordinates are optional; complete endpoint codes and sides are exact.
bool sameDiscussionRange(
  DiffNoteLineRange? expected,
  DiffNoteLineRange? returned,
) {
  if (expected == null || returned == null) return expected == returned;
  bool same(DiffNoteRangeEndpoint? a, DiffNoteRangeEndpoint? b) =>
      a != null &&
      b != null &&
      a.lineCode == b.lineCode &&
      a.type == b.type &&
      (b.oldLine == null || a.oldLine == null || b.oldLine == a.oldLine) &&
      (b.newLine == null || a.newLine == null || b.newLine == a.newLine);
  return same(expected.start, returned.start) &&
      same(expected.end, returned.end);
}

/// Preserve supplied fields and omit null values at every position depth.
Map<String, dynamic> positionedDiscussionPayload(DiffNotePosition position) {
  Map<String, dynamic> withoutNulls(Map<String, dynamic> value) => {
    for (final entry in value.entries)
      if (entry.value != null)
        entry.key: entry.value is Map<String, dynamic>
            ? withoutNulls(entry.value as Map<String, dynamic>)
            : entry.value,
  };
  return withoutNulls(position.toJson());
}
