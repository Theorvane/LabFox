import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/protected_environments/data/protected_environments_repository.dart';
import 'package:labfox/features/protected_environments/presentation/controllers/protected_environments_controller.dart';

class _Repository extends ProtectedEnvironmentsRepository {
  _Repository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  final pages = <int>[];
  var writes = 0;
  bool failWrite = false;
  String? existing;

  @override
  Future<Paginated<ProtectedEnvironment>> list(
    int projectId, {
    int page = 1,
  }) async {
    pages.add(page);
    if (page == 1) {
      return const Paginated(
        items: [ProtectedEnvironment(name: 'staging')],
        nextPage: 2,
      );
    }
    return Paginated(
      items: [if (existing != null) ProtectedEnvironment(name: existing!)],
    );
  }

  @override
  Future<ProtectedEnvironment> createRoleOnly(
    int projectId,
    String name, {
    required int accessLevel,
  }) async {
    writes++;
    if (failWrite) throw const GitLabServerException('Unconfirmed write');
    return ProtectedEnvironment(
      name: name,
      deployAccessLevels: [
        ProtectedEnvironmentAccess(id: 12, accessLevel: accessLevel),
      ],
    );
  }
}

void main() {
  test(
    'checks every page and creates an exact role-only project rule',
    () async {
      final repository = _Repository();
      final container = ProviderContainer(
        overrides: [
          protectedEnvironmentsRepositoryProvider.overrideWith(
            (ref) async => repository,
          ),
        ],
      );
      addTearDown(container.dispose);
      final provider = protectedEnvironmentCreateControllerProvider(7);
      await container
          .read(provider.notifier)
          .create('production', accessLevel: 40);
      expect(repository.pages, [1, 2]);
      expect(repository.writes, 1);
    },
  );

  test('rejects a duplicate on a later page before posting', () async {
    final repository = _Repository()..existing = 'production';
    final container = ProviderContainer(
      overrides: [
        protectedEnvironmentsRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(
      container
          .read(protectedEnvironmentCreateControllerProvider(7).notifier)
          .create('production', accessLevel: 30),
      throwsA(isA<GitLabConflictException>()),
    );
    expect(repository.writes, 0);
  });

  test('surfaces an uncertain write for explicit reinspection', () async {
    final repository = _Repository()..failWrite = true;
    final container = ProviderContainer(
      overrides: [
        protectedEnvironmentsRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(
      container
          .read(protectedEnvironmentCreateControllerProvider(7).notifier)
          .create('production', accessLevel: 40),
      throwsA(isA<GitLabServerException>()),
    );
    expect(repository.writes, 1);
  });
}
