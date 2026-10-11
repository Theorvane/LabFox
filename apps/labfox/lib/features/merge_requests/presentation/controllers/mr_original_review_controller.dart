import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../data/literal_original_diff.dart';
import '../../data/merge_requests_repository.dart';
import '../../data/original_diff_range.dart';
import 'merge_requests_controllers.dart';

typedef MrOriginalReviewRef = ({
  int projectId,
  int iid,
  int mergeRequestId,
  String commitId,
});

bool _fixedSha(String value) =>
    value.length == 40 && !RegExp(r'[^0-9a-f]').hasMatch(value);

/// Read-only original selection state, without a private-write guarantee.
/// Single-parent refs follow GitLab's original commit diff convention.
/// Unknown/root/multiple parents remain unselectable; no blank refs are invented.
class MrOriginalReviewSnapshot {
  MrOriginalReviewSnapshot._(this.context, this.files) {
    final commit = context?.commit, mr = context?.mergeRequest;
    final parents = commit?.parentIds;
    if (commit == null ||
        mr == null ||
        mr.id < 1 ||
        mr.iid < 1 ||
        (mr.targetProjectId ?? 0) < 1 ||
        !_fixedSha(commit.id) ||
        parents == null ||
        parents.length != 1 ||
        !_fixedSha(parents.single) ||
        parents.single == commit.id) {
      return;
    }
    for (final file in files) {
      final codeFor = originalDiffLineCodes(file.file.newPath);
      final positions = Map<DiffLine, DiffNotePosition>.identity();
      final endpoints = Map<DiffLine, DiffNoteRangeEndpoint>.identity();
      for (final hunk in file.hunks) {
        var old = hunk.oldStart, newer = hunk.newStart;
        for (final line in hunk.lines) {
          positions[line] = DiffNotePosition(
            baseSha: parents.single,
            startSha: parents.single,
            headSha: commit.id,
            oldPath: file.file.oldPath,
            newPath: file.file.newPath,
            positionType: 'text',
            oldLine: line.oldLine,
            newLine: line.newLine,
          );
          // Literal range matching supplies the exact code when creating ranges.
          endpoints[line] = DiffNoteRangeEndpoint(
            lineCode: codeFor(old, newer),
            type: line.type == DiffLineType.added ? 'new' : 'old',
            oldLine: line.oldLine,
            newLine: line.newLine,
          );
          if (line.oldLine != null) old++;
          if (line.newLine != null) newer++;
        }
      }
      _positions[file] = positions;
      _endpoints[file] = endpoints;
    }
  }

  factory MrOriginalReviewSnapshot.fromContext(
    MrOriginalCommitContext context,
  ) {
    final captured = (
      mergeRequest: context.mergeRequest,
      commit: context.commit,
      files: List<CommitDiffFile>.unmodifiable(context.files),
    );
    final oldPaths = <String, int>{}, newPaths = <String, int>{};
    for (final file in captured.files) {
      oldPaths.update(file.oldPath, (v) => v + 1, ifAbsent: () => 1);
      newPaths.update(file.newPath, (v) => v + 1, ifAbsent: () => 1);
    }
    return MrOriginalReviewSnapshot._(
      captured,
      List.unmodifiable([
        for (final file in captured.files)
          if (oldPaths[file.oldPath] == 1 && newPaths[file.newPath] == 1)
            ?validateLiteralOriginalDiff(file),
      ]),
    );
  }
  factory MrOriginalReviewSnapshot.unavailable() =>
      MrOriginalReviewSnapshot._(null, const []);

  final MrOriginalCommitContext? context;
  final List<LiteralOriginalDiff> files;
  final _positions = <LiteralOriginalDiff, Map<DiffLine, DiffNotePosition>>{};
  final _endpoints =
      <LiteralOriginalDiff, Map<DiffLine, DiffNoteRangeEndpoint>>{};
  bool get available => context != null;
  bool get canSelect => _positions.values.any((rows) => rows.isNotEmpty);

  DiffNotePosition? positionFor(LiteralOriginalDiff file, DiffLine line) =>
      _positions[file]?[line];

  DiffNotePosition? rangePositionFor(
    LiteralOriginalDiff file,
    DiffLine start,
    DiffLine end,
  ) {
    final positions = _positions[file];
    final anchor = positions?[end];
    if (anchor == null || positions?[start] == null) return null;
    final rows = positions!.keys.toList();
    if (rows.indexOf(start) >= rows.indexOf(end)) return null;
    final range = DiffNoteLineRange(
      start: _endpoints[file]![start],
      end: _endpoints[file]![end],
    );
    final matched = literalOriginalDiffRange(file.file, range);
    return matched == null || matched.length < 2
        ? null
        : anchor.copyWith(lineRange: range);
  }

  List<DiffLine> linesForPosition(DiffNotePosition position) {
    for (final entry in _positions.entries) {
      if (position.lineRange == null) {
        for (final row in entry.value.entries) {
          if (row.value == position) return List.unmodifiable([row.key]);
        }
      } else {
        final lines = literalOriginalDiffRange(
          entry.key.file,
          position.lineRange!,
        );
        if (lines == null || lines.length < 2) continue;
        // Match back to captured row objects; parsing never substitutes UI rows.
        final wanted = lines
            .map((line) => (line.type, line.oldLine, line.newLine, line.text))
            .toSet();
        final captured = entry.value.keys
            .where(
              (row) => wanted.contains((
                row.type,
                row.oldLine,
                row.newLine,
                row.text,
              )),
            )
            .toList();
        if (captured.length == lines.length &&
            rangePositionFor(entry.key, captured.first, captured.last) ==
                position) {
          return List.unmodifiable(captured);
        }
      }
    }
    return const [];
  }
}

/// Captures the complete literal file and MR origin, beyond selected row text.
class MrOriginalReviewSelection {
  MrOriginalReviewSelection._(this.position, this._origin, this._file);
  final DiffNotePosition position;
  final (int, int, int?, int?, String, String) _origin;
  final CommitDiffFile _file;

  static MrOriginalReviewSelection? capture(
    MrOriginalReviewSnapshot snapshot,
    DiffNotePosition position,
  ) {
    if (snapshot.linesForPosition(position).isEmpty) return null;
    final mr = snapshot.context!.mergeRequest;
    final files = snapshot.files.where(
      (f) =>
          f.file.oldPath == position.oldPath &&
          f.file.newPath == position.newPath,
    );
    if (files.length != 1) return null;
    return MrOriginalReviewSelection._(position, (
      mr.id,
      mr.iid,
      mr.targetProjectId,
      mr.sourceProjectId,
      mr.sourceBranch,
      mr.targetBranch,
    ), files.single.file);
  }

  bool matches(MrOriginalReviewSnapshot snapshot) {
    final fresh = capture(snapshot, position);
    return fresh != null && fresh._origin == _origin && fresh._file == _file;
  }
}

/// Captures one account/repository origin and discards obsolete read outcomes.
class MrOriginalReviewController
    extends
        AutoDisposeFamilyAsyncNotifier<
          MrOriginalReviewSnapshot,
          MrOriginalReviewRef
        > {
  int _generation = 0;
  Object _session = Object();
  Object get session => _session;
  void _end() {
    _generation++;
    _session = Object();
  }

  @override
  Future<MrOriginalReviewSnapshot> build(MrOriginalReviewRef arg) async {
    _end();
    ref.onDispose(_end);
    final generation = _generation;
    if (arg.projectId < 1 ||
        arg.iid < 1 ||
        arg.mergeRequestId < 1 ||
        !_fixedSha(arg.commitId)) {
      throw ArgumentError('Invalid original MR commit origin.');
    }
    final account = ref.watch(currentAccountProvider);
    if (account == null || account.user.id < 1) {
      throw const GitLabAuthException(
        'No authenticated original review session.',
      );
    }
    final source = ref.watch(mergeRequestsRepositoryProvider.future);
    bool current() =>
        generation == _generation &&
        ref.read(currentAccountProvider) == account &&
        identical(ref.read(mergeRequestsRepositoryProvider.future), source);
    try {
      final repository = await source;
      if (!current()) return MrOriginalReviewSnapshot.unavailable();
      if (repository == null) {
        throw const GitLabAuthException(
          'No authenticated original review client.',
        );
      }
      final context = await repository.originalCommitContext(
        projectId: arg.projectId,
        iid: arg.iid,
        mergeRequestId: arg.mergeRequestId,
        commitId: arg.commitId,
        isCurrent: current,
      );
      if (!current() || context == null) {
        return MrOriginalReviewSnapshot.unavailable();
      }
      if (context.mergeRequest.id != arg.mergeRequestId ||
          context.mergeRequest.iid != arg.iid ||
          context.mergeRequest.targetProjectId != arg.projectId ||
          context.commit.id != arg.commitId) {
        throw const GitLabServerException('Invalid original review identity.');
      }
      final snapshot = MrOriginalReviewSnapshot.fromContext(context);
      return current() ? snapshot : MrOriginalReviewSnapshot.unavailable();
    } catch (_) {
      if (!current()) return MrOriginalReviewSnapshot.unavailable();
      rethrow;
    }
  }
}

final mrOriginalReviewControllerProvider = AsyncNotifierProvider.autoDispose
    .family<
      MrOriginalReviewController,
      MrOriginalReviewSnapshot,
      MrOriginalReviewRef
    >(MrOriginalReviewController.new);
