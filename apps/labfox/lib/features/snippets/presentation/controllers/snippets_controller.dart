import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/snippets_repository.dart';

final snippetsRepositoryProvider = FutureProvider<SnippetsRepository?>((
  ref,
) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : SnippetsRepository(client);
});

Future<SnippetsRepository> _repository(Ref ref) async {
  final repository = await ref.watch(snippetsRepositoryProvider.future);
  if (repository == null) throw StateError('No authenticated account');
  return repository;
}

final projectSnippetsProvider = FutureProvider.family<List<Snippet>, int>((
  ref,
  projectId,
) async {
  return (await _repository(ref)).list(projectId);
});

/// Creates a project snippet and reloads the list after a successful write.
class CreateSnippetController extends AutoDisposeAsyncNotifier<void> {
  @override
  void build() {}

  Future<Snippet> create({
    required int projectId,
    required String title,
    required String description,
    required String visibility,
    required String filePath,
    required String content,
  }) async {
    final repository = await ref.read(snippetsRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    state = const AsyncLoading();
    try {
      final snippet = await repository.create(
        projectId,
        title: title,
        description: description,
        visibility: visibility,
        filePath: filePath,
        content: content,
      );
      ref.invalidate(projectSnippetsProvider(projectId));
      state = const AsyncData(null);
      return snippet;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final createSnippetControllerProvider =
    AsyncNotifierProvider.autoDispose<CreateSnippetController, void>(
      CreateSnippetController.new,
    );

class UpdateSnippetContentController extends AutoDisposeAsyncNotifier<void> {
  @override
  void build() {}

  Future<Snippet> saveContent({
    required int projectId,
    required int snippetId,
    required String filePath,
    required String content,
  }) async {
    state = const AsyncLoading();
    try {
      final repository = await _repository(ref);
      final snippet = await repository.updateFileContent(
        projectId,
        snippetId,
        filePath: filePath,
        content: content,
      );
      final key = SnippetRef(projectId, snippetId);
      ref.invalidate(snippetRawProvider(key));
      ref.invalidate(projectSnippetProvider(key));
      ref.invalidate(projectSnippetsProvider(projectId));
      state = const AsyncData(null);
      return snippet;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final updateSnippetContentControllerProvider =
    AsyncNotifierProvider.autoDispose<UpdateSnippetContentController, void>(
      UpdateSnippetContentController.new,
    );

class DeleteSnippetFileController extends AutoDisposeAsyncNotifier<void> {
  @override
  void build() {}

  Future<void> delete({
    required int projectId,
    required int snippetId,
    required String filePath,
  }) async {
    state = const AsyncLoading();
    try {
      final repository = await _repository(ref);
      final snippet = await repository.get(projectId, snippetId);
      if (snippet.files.length < 2 ||
          !snippet.files.any((file) => file.path == filePath)) {
        throw StateError('Snippet file cannot be deleted');
      }
      await repository.deleteFile(projectId, snippetId, filePath: filePath);
      final key = SnippetRef(projectId, snippetId);
      ref.invalidate(projectSnippetProvider(key));
      ref.invalidate(projectSnippetsProvider(projectId));
      ref.invalidate(
        snippetFileProvider(SnippetFileRef(projectId, snippetId, filePath)),
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final deleteSnippetFileControllerProvider =
    AsyncNotifierProvider.autoDispose<DeleteSnippetFileController, void>(
      DeleteSnippetFileController.new,
    );

class UpdateSnippetController extends AutoDisposeAsyncNotifier<void> {
  @override
  void build() {}

  Future<Snippet> updateMetadata({
    required int projectId,
    required int snippetId,
    required String title,
    required String description,
    String? visibility,
  }) async {
    state = const AsyncLoading();
    try {
      final repository = await _repository(ref);
      final snippet = await repository.updateMetadata(
        projectId,
        snippetId,
        title: title,
        description: description,
        visibility: visibility,
      );
      ref.invalidate(projectSnippetsProvider(projectId));
      ref.invalidate(projectSnippetProvider(SnippetRef(projectId, snippetId)));
      state = const AsyncData(null);
      return snippet;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final updateSnippetControllerProvider =
    AsyncNotifierProvider.autoDispose<UpdateSnippetController, void>(
      UpdateSnippetController.new,
    );

class DeleteSnippetController extends AutoDisposeAsyncNotifier<void> {
  @override
  void build() {}

  Future<void> delete({required int projectId, required int snippetId}) async {
    state = const AsyncLoading();
    try {
      final repository = await _repository(ref);
      await repository.delete(projectId, snippetId);
      ref.invalidate(projectSnippetsProvider(projectId));
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final deleteSnippetControllerProvider =
    AsyncNotifierProvider.autoDispose<DeleteSnippetController, void>(
      DeleteSnippetController.new,
    );

class SnippetRef {
  const SnippetRef(this.projectId, this.snippetId);
  final int projectId;
  final int snippetId;

  @override
  bool operator ==(Object other) =>
      other is SnippetRef &&
      other.projectId == projectId &&
      other.snippetId == snippetId;
  @override
  int get hashCode => Object.hash(projectId, snippetId);
}

final projectSnippetProvider = FutureProvider.family<Snippet, SnippetRef>((
  ref,
  item,
) async {
  return (await _repository(ref)).get(item.projectId, item.snippetId);
});

final snippetRawProvider = FutureProvider.family<String, SnippetRef>((
  ref,
  item,
) async {
  return (await _repository(ref)).raw(item.projectId, item.snippetId);
});

class SnippetFileRef {
  const SnippetFileRef(this.projectId, this.snippetId, this.path);
  final int projectId;
  final int snippetId;
  final String path;

  @override
  bool operator ==(Object other) =>
      other is SnippetFileRef &&
      other.projectId == projectId &&
      other.snippetId == snippetId &&
      other.path == path;
  @override
  int get hashCode => Object.hash(projectId, snippetId, path);
}

final snippetFileProvider = FutureProvider.family<String, SnippetFileRef>((
  ref,
  item,
) async {
  final snippet = await ref.watch(
    projectSnippetProvider(SnippetRef(item.projectId, item.snippetId)).future,
  );
  final file = snippet.files.firstWhere((file) => file.path == item.path);
  return (await _repository(ref)).file(item.projectId, item.snippetId, file);
});
