import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../diff/data/diff_repository.dart';
import '../../../diff/presentation/controllers/diff_controllers.dart';
import '../../data/original_diff_range.dart';

/// Identifies the original position being read inside an MR conversation.
class MrDiscussionContextRef {
  const MrDiscussionContextRef({
    required this.projectId,
    required this.iid,
    required this.position,
  });
  final int projectId;
  final int iid;
  final DiffNotePosition position;
  @override
  bool operator ==(Object other) =>
      other is MrDiscussionContextRef &&
      other.projectId == projectId &&
      other.iid == iid &&
      other.position == position;
  @override
  int get hashCode => Object.hash(projectId, iid, position);
}

/// Read status for one original hunk, or an unavailable context with a cursor.
class MrDiscussionContext {
  const MrDiscussionContext({
    this.file,
    this.line,
    this.lines = const [],
    this.versionId,
    this.nextPage,
    this.loadingMore = false,
    this.loadMoreFailed = false,
  });
  final FileDiff? file;
  final DiffLine? line;
  final List<DiffLine> lines;
  final int? versionId;
  final int? nextPage;
  final bool loadingMore;
  final bool loadMoreFailed;
}

/// Resolves exact original text positions; never substitutes the current diff.
class MrDiscussionContextController
    extends
        AutoDisposeFamilyAsyncNotifier<
          MrDiscussionContext,
          MrDiscussionContextRef
        > {
  int _generation = 0;
  bool _loadingMore = false;
  Completer<void>? _ended;
  void _endSession() {
    _generation++;
    final ended = _ended;
    if (ended != null && !ended.isCompleted) ended.complete();
  }

  @override
  Future<MrDiscussionContext> build(MrDiscussionContextRef arg) async {
    _endSession();
    _ended = Completer<void>();
    _loadingMore = false;
    ref.onDispose(_endSession);
    if (!_supported(arg.position)) return const MrDiscussionContext();
    final generation = _generation;
    final repo = await ref.watch(diffRepositoryProvider.future);
    if (generation != _generation) return const MrDiscussionContext();
    if (repo == null) {
      throw const GitLabAuthException('No authenticated account.');
    }
    return _readPage(repo, 1, generation);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    final page = current?.nextPage;
    if (_loadingMore || state.isLoading || state.hasError || page == null) {
      return;
    }
    final generation = _generation;
    _loadingMore = true;
    state = AsyncData(MrDiscussionContext(nextPage: page, loadingMore: true));
    try {
      final repo = await Future.any([
        ref.read(diffRepositoryProvider.future),
        _ended!.future.then((_) => null),
      ]);
      if (generation != _generation) return;
      if (repo == null) {
        throw const GitLabAuthException('No authenticated account.');
      }
      final next = await _readPage(repo, page, generation);
      if (generation == _generation) state = AsyncData(next);
    } catch (_) {
      if (generation == _generation) {
        state = AsyncData(
          MrDiscussionContext(nextPage: page, loadMoreFailed: true),
        );
      }
    } finally {
      if (generation == _generation) _loadingMore = false;
    }
  }

  Future<MrDiscussionContext> _readPage(
    DiffRepository repo,
    int page,
    int generation,
  ) async {
    try {
      final versions = await repo.mergeRequestDiffVersions(
        projectId: arg.projectId,
        iid: arg.iid,
        page: page,
      );
      if (generation != _generation) return const MrDiscussionContext();
      final matching = versions.items.where(_sameVersion);
      if (matching.isEmpty) {
        return MrDiscussionContext(nextPage: versions.nextPage);
      }
      final selected = await repo.mergeRequestDiffVersion(
        projectId: arg.projectId,
        iid: arg.iid,
        versionId: matching.first.id,
      );
      if (generation != _generation) return const MrDiscussionContext();
      if (selected.id != matching.first.id || !_sameVersion(selected)) {
        throw const GitLabServerException('Diff version changed during read.');
      }
      if (selected.state != null && selected.state != 'collected') {
        return const MrDiscussionContext();
      }
      final files = selected.files
          ?.where(
            (file) =>
                file.oldPath == arg.position.oldPath &&
                file.newPath == arg.position.newPath,
          )
          .toList();
      if (files == null || files.length != 1) {
        return const MrDiscussionContext();
      }
      final source = files.single;
      if (source.diff == null ||
          source.isTooLarge == true ||
          source.isCollapsed == true) {
        return const MrDiscussionContext();
      }
      final file = FileDiff(
        oldPath: source.oldPath,
        newPath: source.newPath,
        isNew: source.isNew == true,
        isDeleted: source.isDeleted == true,
        isRenamed: source.isRenamed == true || source.oldPath != source.newPath,
        diff: source.diff!,
      );
      final range = arg.position.lineRange;
      final lines = range == null
          ? file.hunks.expand((hunk) => hunk.lines).where(_sameLine).toList()
          : originalDiffRange(file, range);
      if (lines == null ||
          lines.isEmpty ||
          range == null && lines.length != 1) {
        return const MrDiscussionContext();
      }
      return MrDiscussionContext(
        file: file,
        line: lines.last,
        lines: List.unmodifiable(lines),
        versionId: selected.id,
      );
    } catch (_) {
      if (generation != _generation) return const MrDiscussionContext();
      rethrow;
    }
  }

  bool _sameVersion(MergeRequestDiffVersion version) =>
      version.baseCommitSha == arg.position.baseSha &&
      version.startCommitSha == arg.position.startSha &&
      version.headCommitSha == arg.position.headSha;

  bool _sameLine(DiffLine line) {
    final p = arg.position;
    if (p.oldLine != null && p.newLine != null) {
      return line.type == DiffLineType.context &&
          line.oldLine == p.oldLine &&
          line.newLine == p.newLine;
    }
    if (p.oldLine != null) {
      return line.type == DiffLineType.removed && line.oldLine == p.oldLine;
    }
    return line.type == DiffLineType.added && line.newLine == p.newLine;
  }

  static bool _supported(DiffNotePosition p) =>
      p.positionType == 'text' &&
      [
        p.baseSha,
        p.startSha,
        p.headSha,
        p.oldPath,
        p.newPath,
      ].every((value) => value != null && value.trim().isNotEmpty) &&
      (p.lineRange != null
          ? supportsOriginalDiffRange(p.lineRange!)
          : p.oldLine != null || p.newLine != null) &&
      (p.oldLine == null || p.oldLine! > 0) &&
      (p.newLine == null || p.newLine! > 0);
}

final mrDiscussionContextControllerProvider = AsyncNotifierProvider.autoDispose
    .family<
      MrDiscussionContextController,
      MrDiscussionContext,
      MrDiscussionContextRef
    >(MrDiscussionContextController.new);
