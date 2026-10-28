import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_discussions_controller.dart';
import 'mr_pending_review_publish_test.dart' as p;
import 'mr_pending_review_save_test.dart' as b;

MergeRequestReviewer reviewer(String state, {int id = 23}) =>
    MergeRequestReviewer(
      user: User(
        id: id,
        username: 'reviewer',
        name: 'Reviewer',
        state: 'active',
      ),
      state: state,
    );

class Drafts extends p.Drafts {
  Drafts(super.client);
  final reviewerPages = <int, Object>{
    1: const Paginated<MergeRequestReviewer>(items: []),
  };
  final reviewerReads = <int>[];
  final submissions = <(String?, ReviewerSubmissionState?)>[];
  String? appliedState;
  void Function()? afterWrite;
  void Function(int)? onRead;
  @override
  Future<Paginated<MergeRequestReviewer>> reviewers({
    required int projectId,
    required int iid,
    int page = 1,
    int perPage = 20,
  }) async {
    expect((projectId, iid), (8, 142));
    reviewerReads.add(page);
    onRead?.call(reviewerReads.length);
    final result = reviewerPages[page]!;
    if (result is Future<Paginated<MergeRequestReviewer>>) return result;
    if (result is Paginated<MergeRequestReviewer>) return result;
    throw result;
  }

  @override
  Future<void> publish({
    required int projectId,
    required int iid,
    required int mergeRequestId,
    String? summaryNote,
    ReviewerSubmissionState? reviewerState,
  }) async {
    submissions.add((summaryNote, reviewerState));
    await super.publish(
      projectId: projectId,
      iid: iid,
      mergeRequestId: mergeRequestId,
      summaryNote: summaryNote,
      reviewerState: reviewerState,
    );
    afterWrite?.call();
    if (appliedState != null) {
      reviewerPages[1] = Paginated(items: [reviewer(appliedState!)]);
    }
  }
}

class Fixture extends b.Fixture {
  late final private = Drafts(api);
  Future<void> initialize() async {
    c.read(b.draftState.notifier).state = Future.value(private);
    private.pages[1] = b.page([b.draft(7)]);
    comments.pageResult = const Paginated<Discussion>(items: []);
    await ready();
  }

  Future<MrPendingReviewPublication> prepare() async => (await controller
      .preparePendingReviewPublication(includeReviewerState: true))!;
}

void main() {
  for (final boundary in [2, 3]) {
    for (final change in [
      'client',
      'drafts',
      'details',
      'comments',
      'origin',
    ]) {
      test(
        'reviewer read boundary $boundary isolates obsolete $change',
        () async {
          final f = Fixture();
          await f.initialize();
          final s = await f.prepare();
          f.private.appliedState = 'reviewed';
          var current = true;
          f.private.onRead = (count) {
            if (count != boundary) return;
            scheduleMicrotask(() {
              switch (change) {
                case 'client':
                  f.c.read(b.clientState.notifier).state = Future.value(
                    b.client(),
                  );
                case 'drafts':
                  f.c.read(b.draftState.notifier).state = Future.value(
                    Drafts(f.api),
                  );
                case 'details':
                  f.c.read(b.sourceState.notifier).state = Future.value(
                    b.Details(f.api),
                  );
                case 'comments':
                  f.c.read(b.commentsState.notifier).state = Future.value(
                    b.Comments(f.api),
                  );
                case 'origin':
                  current = false;
              }
            });
          };
          expect(
            await f.controller.publishPendingReview(
              s,
              reviewerState: ReviewerSubmissionState.reviewed,
              isCurrent: () => current,
            ),
            false,
          );
          expect(f.private.submissions.length, boundary == 2 ? 0 : 1);
          expect(f.controller.pendingPublicationNeedsInspection, boundary == 3);
        },
      );
    }
  }
  test(
    'required reviewer inspection waits for actual cancelled write settlement',
    () async {
      final f = Fixture();
      await f.initialize();
      final s = await f.prepare();
      final write = Completer<void>();
      f.private.publication = write.future;
      final pending = f.controller.publishPendingReview(
        s,
        reviewerState: ReviewerSubmissionState.reviewed,
      );
      while (f.private.submissions.isEmpty) {
        await Future<void>.delayed(Duration.zero);
      }
      f.c.read(b.clientState.notifier).state = Future.value(b.client());
      expect(await pending, false);
      await f.ready();
      final before = f.private.reviewerReads.length;
      final inspection = f.controller.inspectPendingReviewPublication();
      await Future<void>.delayed(Duration.zero);
      expect(f.private.reviewerReads.length, before);
      expect(f.controller.pendingPublicationNeedsInspection, true);
      write.complete();
      expect((await inspection)!.pending.reviewerStateAvailable, true);
      expect(f.controller.pendingPublicationNeedsInspection, false);
      expect(f.private.submissions.length, 1);
    },
  );

  test(
    'preparation reads every reviewer page and preserves separate account state',
    () async {
      final f = Fixture();
      await f.initialize();
      f.private.reviewerPages[1] = const Paginated<MergeRequestReviewer>(
        items: [],
        nextPage: 3,
      );
      f.private.reviewerPages[3] = Paginated(items: [reviewer('unreviewed')]);
      final s = await f.prepare();
      expect(s.reviewerStateAvailable, true);
      expect(s.reviewer!.state, 'unreviewed');
      expect(s.reviewer!.user.state, 'active');
      expect(f.private.reviewerReads, [1, 3]);
    },
  );
  for (final state in ReviewerSubmissionState.values) {
    test('one exact public summary and $state with state readback', () async {
      final f = Fixture();
      await f.initialize();
      final s = await f.prepare();
      f.private.appliedState = state.value;
      expect(
        await f.controller.publishPendingReview(
          s,
          summaryNote: '  **Summary**\n ',
          reviewerState: state,
        ),
        true,
      );
      expect(f.private.submissions, [('  **Summary**\n ', state)]);
      expect(f.private.reviewerReads, [1, 1, 1]);
      expect(f.controller.pendingPublicationNeedsInspection, false);
    });
    test('state-only review can start with no private drafts $state', () async {
      final f = Fixture();
      await f.initialize();
      f.private.pages[1] = b.page([]);
      final s = await f.prepare();
      f.private.appliedState = state.value;
      expect(
        await f.controller.publishPendingReview(s, reviewerState: state),
        true,
      );
      expect(f.private.submissions, [(null, state)]);
    });
  }
  test(
    'summary-only review needs no private draft or reviewer endpoint',
    () async {
      final f = Fixture();
      await f.initialize();
      f.private.pages[1] = b.page([]);
      f.private.reviewerPages[1] = const GitLabNotFoundException('Unavailable');
      final s = await f.prepare();
      expect(s.reviewerStateAvailable, false);
      expect(
        await f.controller.publishPendingReview(s, summaryNote: 'Summary'),
        true,
      );
      expect(f.private.submissions, [('Summary', null)]);
    },
  );
  test('changed reviewer state blocks all publication before write', () async {
    final f = Fixture();
    await f.initialize();
    final s = await f.prepare();
    f.private.reviewerPages[1] = Paginated(items: [reviewer('reviewed')]);
    await expectLater(
      f.controller.publishPendingReview(
        s,
        reviewerState: ReviewerSubmissionState.requestedChanges,
      ),
      throwsA(isA<GitLabConflictException>()),
    );
    expect(f.private.submissions, isEmpty);
  });
  test('reviewed cannot replace existing formal approval', () async {
    final f = Fixture();
    await f.initialize();
    f.private.reviewerPages[1] = Paginated(items: [reviewer('approved')]);
    final s = await f.prepare();
    await expectLater(
      f.controller.publishPendingReview(
        s,
        reviewerState: ReviewerSubmissionState.reviewed,
      ),
      throwsA(isA<GitLabConflictException>()),
    );
    expect(f.private.submissions, isEmpty);
  });
  for (final result in [
    const Paginated<MergeRequestReviewer>(items: []),
    const GitLabServerException('Readback failed'),
    Paginated(items: [reviewer('unreviewed')]),
  ]) {
    test(
      '204 without matching reviewer readback keeps shared recovery gate $result',
      () async {
        final f = Fixture();
        await f.initialize();
        final s = await f.prepare();
        f.private.appliedState = null;
        // A successful mutation may leave status unchanged; response status cannot prove it.
        if (result is GitLabException) {
          f.private.afterWrite = () {
            f.private.reviewerPages[1] = result;
          };
        } else if (result is Paginated<MergeRequestReviewer>) {
          f.private.afterWrite = () {
            f.private.reviewerPages[1] = result;
          };
        }
        await expectLater(
          f.controller.publishPendingReview(
            s,
            reviewerState: ReviewerSubmissionState.reviewed,
          ),
          throwsA(isA<GitLabServerException>()),
        );
        expect(f.controller.pendingPublicationNeedsInspection, true);
        expect(f.private.submissions.length, 1);
        f.private.reviewerPages[1] = const GitLabServerException(
          'Cannot inspect state',
        );
        await expectLater(
          f.controller.inspectPendingReviewPublication(),
          throwsA(isA<GitLabServerException>()),
        );
        expect(f.controller.pendingPublicationNeedsInspection, true);
        f.private.reviewerPages[1] = Paginated(
          items: [reviewer('requested_changes')],
        );
        final inspection = (await f.controller
            .inspectPendingReviewPublication())!;
        expect(inspection.pending.reviewerStateAvailable, true);
        expect(
          inspection.pending.forNote(7)!.reviewer!.state,
          'requested_changes',
        );
        expect(f.controller.pendingPublicationNeedsInspection, false);
      },
    );
  }
  for (final page in [
    Paginated(items: [reviewer('reviewed'), reviewer('reviewed')]),
    const Paginated<MergeRequestReviewer>(items: [], nextPage: 1),
  ]) {
    test(
      'invalid reviewer pagination prevents outcome authorization $page',
      () async {
        final f = Fixture();
        await f.initialize();
        f.private.reviewerPages[1] = page;
        final s = await f.prepare();
        expect(s.reviewerStateAvailable, false);
        expect(
          await f.controller.publishPendingReview(
            s,
            reviewerState: ReviewerSubmissionState.reviewed,
          ),
          false,
        );
        expect(f.private.submissions, isEmpty);
      },
    );
  }
}
