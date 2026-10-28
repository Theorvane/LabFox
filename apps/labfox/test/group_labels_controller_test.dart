import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:labfox/features/project_labels/data/group_labels_repository.dart';
import 'package:labfox/features/project_labels/presentation/controllers/group_labels_controller.dart';

class _FakeRepository extends GroupLabelsRepository {
  _FakeRepository()
    : super(
        GitLabClient(
          baseUrl: 'https://gitlab.example.com',
          token: 'glpat-xxxxxxxxxxxx',
        ),
      );

  int reads = 0;
  final created = <String>[];

  @override
  Future<List<ProjectLabel>> list(int groupId) async {
    expect(groupId, 42);
    reads++;
    return [
      for (var i = 0; i < created.length; i++)
        ProjectLabel(id: i + 1, name: created[i], color: '#5843AD'),
    ];
  }

  @override
  Future<ProjectLabel> create(
    int groupId, {
    required String name,
    required String color,
    String? description,
  }) async {
    expect(groupId, 42);
    expect(color, '#5843AD');
    created.add(name);
    return ProjectLabel(id: created.length, name: name, color: color);
  }
}

void main() {
  test('refreshes group labels after creation', () async {
    final repository = _FakeRepository();
    final container = ProviderContainer(
      overrides: [
        groupLabelsRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final provider = groupLabelsControllerProvider(42);
    expect(await container.read(provider.future), isEmpty);
    await container
        .read(provider.notifier)
        .create(name: 'feature', color: '#5843AD');
    expect(repository.reads, 2);
    expect(container.read(provider).requireValue.single.name, 'feature');
  });
}
