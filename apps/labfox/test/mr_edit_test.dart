import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/merge_requests/data/mr_actions_repository.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/merge_requests_controllers.dart';
import 'package:labfox/features/merge_requests/presentation/controllers/mr_actions_controller.dart';

class _FakeRepo extends MrActionsRepository {
  _FakeRepo() : super(GitLabClient(baseUrl: 'https://gitlab.com', token: 'x'));
  final calls = <String>[];

  @override
  Future<MergeRequestApprovals?> approvals({
    required int projectId,
    required int iid,
  }) async => null;

  MergeRequest _mr(String title, String state) => MergeRequest(
    id: 1,
    iid: 5,
    title: title,
    state: state,
    sourceBranch: 'a',
    targetBranch: 'b',
  );

  @override
  Future<MergeRequest> setOpen({
    required int projectId,
    required int iid,
    required bool open,
  }) async {
    calls.add('setOpen:$open');
    return _mr('x', open ? 'opened' : 'closed');
  }

  @override
  Future<MergeRequest> setDraft({
    required int projectId,
    required int iid,
    required bool draft,
    required String title,
  }) async {
    calls.add('setDraft:$draft:$title');
    return _mr(title, 'opened');
  }

  @override
  Future<void> rebase({required int projectId, required int iid}) async {
    calls.add('rebase');
  }

  @override
  Future<MergeRequest?> setSubscription({
    required int projectId,
    required int iid,
    required bool subscribed,
  }) async {
    calls.add('setSubscription:$subscribed');
    return null;
  }
}

void main() {
  test(
    'the controller routes setOpen, setDraft and rebase to the repo',
    () async {
      final repo = _FakeRepo();
      final container = ProviderContainer(
        overrides: [
          mrActionsRepositoryProvider.overrideWith((ref) async => repo),
        ],
      );
      addTearDown(container.dispose);
      const ref = MergeRequestRef(projectId: 7, iid: 5);
      final notifier = container.read(
        mrActionsControllerProvider(ref).notifier,
      );

      await notifier.setOpen(false);
      await notifier.setDraft(draft: true, title: 'Add OAuth');
      await notifier.rebase();
      await notifier.setSubscription(true);

      expect(repo.calls, [
        'setOpen:false',
        'setDraft:true:Add OAuth',
        'rebase',
        'setSubscription:true',
      ]);
    },
  );
}
