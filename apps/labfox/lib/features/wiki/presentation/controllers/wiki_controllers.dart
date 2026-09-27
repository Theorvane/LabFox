import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';

import '../../../../core/auth/gitlab_client_provider.dart';
import '../../data/wiki_repository.dart';

final wikiRepositoryProvider = FutureProvider<WikiRepository?>((ref) async {
  final client = await ref.watch(gitLabClientProvider.future);
  return client == null ? null : WikiRepository(client);
});

/// Lists pages for one project wiki.
class WikiPagesController extends FamilyAsyncNotifier<List<WikiPage>, int> {
  @override
  Future<List<WikiPage>> build(int arg) async {
    final repository = await ref.watch(wikiRepositoryProvider.future);
    if (repository == null) {
      throw StateError('No authenticated account');
    }
    return repository.pages(arg);
  }

  /// Creates a page, then reloads the list so it appears after navigation.
  Future<WikiPage> create({
    required String title,
    required String content,
  }) async {
    final repository = await ref.read(wikiRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    final page = await repository.create(arg, title: title, content: content);
    ref.invalidateSelf();
    return page;
  }
}

final wikiPagesControllerProvider =
    AsyncNotifierProvider.family<WikiPagesController, List<WikiPage>, int>(
      WikiPagesController.new,
    );

/// Identifies a wiki page independently of the list that opened it.
class WikiPageRef {
  const WikiPageRef({required this.projectId, required this.slug});

  final int projectId;
  final String slug;

  @override
  bool operator ==(Object other) =>
      other is WikiPageRef &&
      other.projectId == projectId &&
      other.slug == slug;

  @override
  int get hashCode => Object.hash(projectId, slug);
}

/// Loads a single page for direct links and restored navigation.
class WikiPageController extends FamilyAsyncNotifier<WikiPage, WikiPageRef> {
  @override
  Future<WikiPage> build(WikiPageRef arg) async {
    final repository = await ref.watch(wikiRepositoryProvider.future);
    if (repository == null) {
      throw StateError('No authenticated account');
    }
    return repository.page(arg.projectId, arg.slug);
  }

  /// Saves a draft and refreshes the project page list after a successful write.
  Future<WikiPage> save({
    required WikiPage original,
    required String title,
    required String content,
  }) async {
    final repository = await ref.read(wikiRepositoryProvider.future);
    if (repository == null) throw StateError('No authenticated account');
    final updated = await repository.update(
      projectId: arg.projectId,
      original: original,
      title: title,
      content: content,
    );
    state = AsyncData(updated);
    ref.invalidate(wikiPagesControllerProvider(arg.projectId));
    return updated;
  }
}

final wikiPageControllerProvider =
    AsyncNotifierProvider.family<WikiPageController, WikiPage, WikiPageRef>(
      WikiPageController.new,
    );
