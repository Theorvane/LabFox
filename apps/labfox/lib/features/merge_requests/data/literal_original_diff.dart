import 'package:gitlab_models/gitlab_models.dart';

/// Literal metadata and deeply immutable, complete original diff hunks.
typedef LiteralOriginalDiff = ({CommitDiffFile file, List<DiffHunk> hunks});

final _header = RegExp(
  r'^@@ -(0|[1-9][0-9]*)(?:,(0|[1-9][0-9]*))? '
  r'\+(0|[1-9][0-9]*)(?:,(0|[1-9][0-9]*))? @@(?: [^\r\n]*)?$',
);
// Conservative coordinate bound for review positions, across supported runtimes.
const _maxCoordinate = 2147483647;

bool _supportedPath(String path) =>
    path.isNotEmpty &&
    !path.startsWith('/') &&
    !path.contains(RegExp(r'[\x00\r\n]')) &&
    path
        .split('/')
        .every((part) => part.isNotEmpty && part != '.' && part != '..');

/// Returns null for unsupported or incomplete input; never repairs raw text.
/// Valid local hunks alone do not establish original refs or write eligibility.
LiteralOriginalDiff? validateLiteralOriginalDiff(CommitDiffFile file) {
  if (!_supportedPath(file.oldPath) ||
      !_supportedPath(file.newPath) ||
      file.isCollapsed == true ||
      file.isTooLarge == true ||
      (file.isNew && file.isDeleted) ||
      (file.isRenamed && (file.isNew || file.isDeleted)) ||
      (file.isRenamed
          ? file.oldPath == file.newPath
          : file.oldPath != file.newPath)) {
    return null;
  }
  final text = file.diff;
  if (text == null || text.isEmpty) return null;
  final raw = text.split('\n');
  // Only the final delimiter is framing, never an empty body line.
  if (raw.last.isEmpty) raw.removeLast();
  final hunks = <DiffHunk>[];
  List<DiffLine>? lines;
  var oldStart = 0, newStart = 0, oldCount = 0, newCount = 0;
  var old = 0, newer = 0, previousOldEnd = -1, previousNewEnd = -1;
  var endedOld = false, endedNew = false, markerAllowed = false;
  var header = '';
  DiffLineType? previousType;

  bool finish() {
    if (lines == null) return true;
    if (old - oldStart != oldCount || newer - newStart != newCount) {
      return false;
    }
    hunks.add(
      DiffHunk(
        oldStart: oldStart,
        newStart: newStart,
        header: header,
        lines: List<DiffLine>.unmodifiable(lines),
      ),
    );
    previousOldEnd = oldStart + (oldCount == 0 ? 1 : oldCount);
    previousNewEnd = newStart + (newCount == 0 ? 1 : newCount);
    return true;
  }

  for (final row in raw) {
    final match = _header.firstMatch(row);
    if (match != null) {
      if (!finish()) return null;
      final values = [
        int.tryParse(match.group(1)!),
        int.tryParse(match.group(3)!),
        int.tryParse(match.group(2) ?? '1'),
        int.tryParse(match.group(4) ?? '1'),
      ];
      if (values.any((v) => v == null || v > _maxCoordinate)) return null;
      oldStart = values[0]!;
      newStart = values[1]!;
      oldCount = values[2]!;
      newCount = values[3]!;
      if ((oldCount == 0 && newCount == 0) ||
          (oldCount > 0 && oldStart == 0) ||
          (newCount > 0 && newStart == 0) ||
          oldStart + oldCount > _maxCoordinate ||
          newStart + newCount > _maxCoordinate ||
          (file.isNew &&
              (oldStart != 0 ||
                  oldCount != 0 ||
                  newStart != 1 ||
                  hunks.isNotEmpty)) ||
          (file.isDeleted &&
              (newStart != 0 ||
                  newCount != 0 ||
                  oldStart != 1 ||
                  hunks.isNotEmpty))) {
        return null;
      }
      final effectiveOld = oldStart + (oldCount == 0 ? 1 : 0);
      final effectiveNew = newStart + (newCount == 0 ? 1 : 0);
      if (previousOldEnd >= 0 &&
          (effectiveOld < previousOldEnd ||
              effectiveNew < previousNewEnd ||
              effectiveOld - previousOldEnd != effectiveNew - previousNewEnd)) {
        return null;
      }
      old = oldStart;
      newer = newStart;
      header = row;
      lines = <DiffLine>[];
      markerAllowed = false;
      continue;
    }
    if (lines == null || row.isEmpty) return null;
    if (row == r'\ No newline at end of file') {
      if (!markerAllowed) return null;
      if (previousType != DiffLineType.added) endedOld = true;
      if (previousType != DiffLineType.removed) endedNew = true;
      markerAllowed = false;
      continue;
    }
    final DiffLineType type;
    switch (row[0]) {
      case ' ':
        type = DiffLineType.context;
      case '-':
        type = DiffLineType.removed;
      case '+':
        type = DiffLineType.added;
      default:
        return null;
    }
    final usesOld = type != DiffLineType.added,
        usesNew = type != DiffLineType.removed;
    if ((usesOld && (endedOld || old - oldStart >= oldCount)) ||
        (usesNew && (endedNew || newer - newStart >= newCount))) {
      return null;
    }
    lines.add(
      DiffLine(
        type: type,
        text: row.substring(1),
        oldLine: usesOld ? old++ : null,
        newLine: usesNew ? newer++ : null,
      ),
    );
    previousType = type;
    markerAllowed = true;
  }
  if (!finish() || hunks.isEmpty) return null;
  return (file: file, hunks: List<DiffHunk>.unmodifiable(hunks));
}
