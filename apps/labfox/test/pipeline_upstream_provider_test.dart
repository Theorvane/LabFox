import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/pipelines/data/pipelines_repository.dart';
import 'package:labfox/features/pipelines/presentation/controllers/pipelines_controllers.dart';

class Repository extends PipelinesRepository {
  Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );
  final calls = <PipelineRef>[];
  Completer<PipelineUpstream?>? pending;
  bool fail = false;
  bool failAction = false;
  PipelineUpstream? value = const PipelineUpstream(
    id: 'gid://gitlab/Ci::Pipeline/33',
    status: 'RUNNING',
    project: PipelineUpstreamProject(id: 'gid://gitlab/Project/8'),
  );
  @override
  Future<PipelineUpstream?> upstream({
    required int projectId,
    required int pipelineId,
  }) async {
    calls.add(PipelineRef(projectId: projectId, pipelineId: pipelineId));
    if (pending != null) return pending!.future;
    if (fail) throw const GitLabForbiddenException('private');
    return value;
  }

  @override
  Future<Pipeline> retry({
    required int projectId,
    required int pipelineId,
  }) async {
    if (failAction) throw const GitLabForbiddenException('private');
    return Pipeline(id: pipelineId, status: 'pending');
  }

  @override
  Future<Pipeline> cancel({required int projectId, required int pipelineId}) =>
      retry(projectId: projectId, pipelineId: pipelineId);
}

void main() {
  const key = PipelineRef(projectId: 7, pipelineId: 944);
  final provider = pipelineUpstreamProvider(key);
  late Repository repo;
  late ProviderContainer container;
  setUp(() {
    repo = Repository();
    container = ProviderContainer(
      overrides: [pipelinesRepositoryProvider.overrideWith((_) async => repo)],
    );
  });
  tearDown(() => container.dispose());
  test(
    'loads exact pipeline and separates families; null is a successful unavailable read',
    () async {
      expect((await container.read(provider.future))?.pipelineId, 33);
      expect(repo.calls, [key]);
      repo.value = null;
      expect(
        await container.read(
          pipelineUpstreamProvider(
            const PipelineRef(projectId: 8, pipelineId: 33),
          ).future,
        ),
        isNull,
      );
      expect(repo.calls.last, const PipelineRef(projectId: 8, pipelineId: 33));
    },
  );
  test('failure can be retried explicitly', () async {
    repo.fail = true;
    await expectLater(
      container.read(provider.future),
      throwsA(isA<GitLabForbiddenException>()),
    );
    repo.fail = false;
    expect((await container.refresh(provider.future))?.pipelineId, 33);
    expect(repo.calls.length, 2);
  });
  test(
    'refresh and account-source replacement ignore old first responses',
    () async {
      repo.pending = Completer();
      container.listen(provider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      final old = repo.pending!;
      final replacement = Repository()
        ..value = const PipelineUpstream(
          id: 'gid://gitlab/Ci::Pipeline/35',
          status: 'SUCCESS',
          project: PipelineUpstreamProject(id: 'gid://gitlab/Project/9'),
        );
      container.updateOverrides([
        pipelinesRepositoryProvider.overrideWith((_) async => replacement),
      ]);
      container.invalidate(pipelinesRepositoryProvider);
      expect((await container.read(provider.future))?.pipelineId, 35);
      old.complete(repo.value);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(provider).requireValue?.pipelineId, 35);
      replacement.pending = Completer();
      container.invalidate(provider);
      await Future<void>.delayed(Duration.zero);
      final stale = replacement.pending!;
      replacement.pending = null;
      await container.refresh(provider.future);
      stale.complete(repo.value);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(provider).requireValue?.pipelineId, 35);
    },
  );
  test('logout remains an error after old upstream completion', () async {
    repo.pending = Completer();
    container.listen(provider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    final old = repo.pending!;
    container.updateOverrides([
      pipelinesRepositoryProvider.overrideWith((_) async => null),
    ]);
    container.invalidate(pipelinesRepositoryProvider);
    await expectLater(
      container.read(provider.future),
      throwsA(isA<StateError>()),
    );
    old.complete(repo.value);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(provider).hasError, isTrue);
  });
  test(
    'successful retry/cancel refresh upstream while a failed action preserves it',
    () async {
      await container.read(provider.future);
      final action = container.read(
        pipelineActionsControllerProvider(key).notifier,
      );
      await action.retry();
      await container.read(provider.future);
      await action.cancel();
      await container.read(provider.future);
      expect(repo.calls.length, 3);
      repo.failAction = true;
      await expectLater(
        action.retry(),
        throwsA(isA<GitLabForbiddenException>()),
      );
      await container.read(provider.future);
      expect(repo.calls.length, 3);
    },
  );
}
