import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../diff/presentation/controllers/diff_controllers.dart';
import '../../data/review_diff_range.dart';
import 'merge_requests_controllers.dart';

/// The authoritative latest version displayed for positioned review.
class MrReviewSnapshot {
  MrReviewSnapshot({
    this.version,
    this.files = const [],
    this.unavailable = false,
  });
  final MergeRequestDiffVersion? version;
  final List<FileDiff> files;
  final bool unavailable;

  late final Map<FileDiff, Map<DiffLine, DiffNotePosition>> _positions =
      _buildPositions();
  DiffNotePosition? positionFor(FileDiff file, DiffLine line) =>
      _positions[file]?[line];
  late final _ranges = Map<FileDiff, ReviewDiffRange>.identity()
    ..addEntries(
      _positions.keys.map((file) => MapEntry(file, ReviewDiffRange(file))),
    );

  DiffNotePosition? rangePositionFor(
    FileDiff file,
    DiffLine start,
    DiffLine end,
  ) {
    if (positionFor(file, start) == null) return null;
    final anchor = positionFor(file, end);
    final range = _ranges[file]?.between(start, end);
    return anchor == null || range == null
        ? null
        : anchor.copyWith(lineRange: range);
  }

  List<DiffLine> linesForPosition(FileDiff file, DiffNotePosition position) {
    if (position.oldPath != file.oldPath ||
        position.newPath != file.newPath ||
        position.baseSha != version?.baseCommitSha ||
        position.startSha != version?.startCommitSha ||
        position.headSha != version?.headCommitSha) {
      return const [];
    }
    if (position.lineRange != null) {
      return _ranges[file]?.matching(position.lineRange!) ?? const [];
    }
    return [
      for (final entry in (_positions[file] ?? {}).entries)
        if (entry.value == position) entry.key,
    ];
  }

  bool containsPosition(DiffNotePosition position) {
    if (position.lineRange == null) {
      return _positions.values.any((lines) => lines.values.contains(position));
    }
    for (final file in _positions.keys) {
      final lines = linesForPosition(file, position);
      if (lines.length > 1 &&
          rangePositionFor(file, lines.first, lines.last) == position) {
        return true;
      }
    }
    return false;
  }

  Map<FileDiff, Map<DiffLine, DiffNotePosition>> _buildPositions() {
    final result = Map<FileDiff, Map<DiffLine, DiffNotePosition>>.identity();
    final v = version;
    if (unavailable || v == null) return result;
    final paths = <(String, String), int>{};
    for (final f in files) {
      final key = (f.oldPath, f.newPath);
      paths[key] = (paths[key] ?? 0) + 1;
    }
    for (final file in files) {
      if (file.isTooLarge ||
          file.isCollapsed ||
          file.isBinary ||
          file.isOmitted ||
          paths[(file.oldPath, file.newPath)] != 1) {
        continue;
      }
      final lines = file.hunks.expand((h) => h.lines).toList();
      final coordinates = <(DiffLineType, int?, int?), int>{};
      for (final line in lines) {
        final key = (line.type, line.oldLine, line.newLine);
        coordinates[key] = (coordinates[key] ?? 0) + 1;
      }
      final eligible = Map<DiffLine, DiffNotePosition>.identity();
      for (final line in lines) {
        if (coordinates[(line.type, line.oldLine, line.newLine)] != 1) continue;
        final valid = switch (line.type) {
          DiffLineType.added => line.oldLine == null && (line.newLine ?? 0) > 0,
          DiffLineType.removed =>
            line.newLine == null && (line.oldLine ?? 0) > 0,
          DiffLineType.context =>
            (line.oldLine ?? 0) > 0 && (line.newLine ?? 0) > 0,
        };
        if (!valid) continue;
        eligible[line] = DiffNotePosition(
          baseSha: v.baseCommitSha,
          startSha: v.startCommitSha,
          headSha: v.headCommitSha,
          oldPath: file.oldPath,
          newPath: file.newPath,
          positionType: 'text',
          oldLine: line.oldLine,
          newLine: line.newLine,
        );
      }
      result[file] = eligible;
    }
    return result;
  }
}

/// An immutable selected-text fingerprint, captured before any fresh reads.
class MrReviewSelection {
  MrReviewSelection._(this.position, this.versionId, this.lines);
  final DiffNotePosition position;
  final int versionId;
  final List<(DiffLineType, int?, int?, String)> lines;

  static MrReviewSelection? capture(
    MrReviewSnapshot snapshot,
    DiffNotePosition position,
  ) {
    if (!snapshot.containsPosition(position)) return null;
    final selected = [
      for (final file in snapshot.files)
        for (final line in snapshot.linesForPosition(file, position))
          (line.type, line.oldLine, line.newLine, line.text),
    ];
    if (selected.isEmpty) return null;
    return MrReviewSelection._(
      position,
      snapshot.version!.id,
      List.unmodifiable(selected),
    );
  }

  bool matches(MrReviewSnapshot snapshot) {
    final fresh = capture(snapshot, position);
    return fresh != null &&
        fresh.versionId == versionId &&
        fresh.lines.length == lines.length &&
        Iterable<int>.generate(
          lines.length,
        ).every((index) => fresh.lines[index] == lines[index]);
  }
}

class MrReviewSnapshotController
    extends AutoDisposeFamilyAsyncNotifier<MrReviewSnapshot, MergeRequestRef> {
  int _generation = 0;
  Object _session = Object();
  Object get session => _session;
  void _end() {
    _generation++;
    _session = Object();
  }

  @override
  Future<MrReviewSnapshot> build(MergeRequestRef arg) async {
    _end();
    ref.onDispose(_end);
    final generation = _generation;
    try {
      final repo = await ref.watch(diffRepositoryProvider.future);
      if (generation != _generation) return MrReviewSnapshot(unavailable: true);
      if (repo == null) {
        throw const GitLabAuthException('No authenticated account.');
      }
      final versions = await repo.mergeRequestDiffVersions(
        projectId: arg.projectId,
        iid: arg.iid,
      );
      if (generation != _generation) return MrReviewSnapshot(unavailable: true);
      if (versions.items.isEmpty) return MrReviewSnapshot(unavailable: true);
      final latest = versions.items.first;
      if ([
        latest.baseCommitSha,
        latest.startCommitSha,
        latest.headCommitSha,
      ].any((s) => s == null || s.trim().isEmpty)) {
        return MrReviewSnapshot(unavailable: true);
      }
      final selected = await repo.mergeRequestDiffVersion(
        projectId: arg.projectId,
        iid: arg.iid,
        versionId: latest.id,
      );
      if (generation != _generation) return MrReviewSnapshot(unavailable: true);
      if (selected.id != latest.id ||
          selected.baseCommitSha != latest.baseCommitSha ||
          selected.startCommitSha != latest.startCommitSha ||
          selected.headCommitSha != latest.headCommitSha) {
        throw const GitLabServerException('Diff version changed during read.');
      }
      if (selected.files == null ||
          (selected.state != null && selected.state != 'collected')) {
        return MrReviewSnapshot(unavailable: true);
      }
      return MrReviewSnapshot(
        version: selected,
        files: List.unmodifiable([
          for (final f in selected.files!)
            FileDiff(
              oldPath: f.oldPath,
              newPath: f.newPath,
              isNew: f.isNew == true,
              isDeleted: f.isDeleted == true,
              isRenamed: f.isRenamed == true || f.oldPath != f.newPath,
              diff: f.diff ?? '',
              isTooLarge: f.isTooLarge == true,
              isCollapsed: f.isCollapsed == true || f.diff == null,
            ),
        ]),
      );
    } catch (_) {
      if (generation != _generation) return MrReviewSnapshot(unavailable: true);
      rethrow;
    }
  }
}

final mrReviewSnapshotControllerProvider = AsyncNotifierProvider.autoDispose
    .family<MrReviewSnapshotController, MrReviewSnapshot, MergeRequestRef>(
      MrReviewSnapshotController.new,
    );
