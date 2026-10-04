import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../diff/presentation/controllers/diff_controllers.dart';
import 'merge_requests_controllers.dart';

/// The authoritative latest version displayed for single-line review.
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
  bool containsPosition(DiffNotePosition position) =>
      _positions.values.any((lines) => lines.values.contains(position));

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

class MrReviewSnapshotController
    extends AutoDisposeFamilyAsyncNotifier<MrReviewSnapshot, MergeRequestRef> {
  int _generation = 0;
  void _end() => _generation++;
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
