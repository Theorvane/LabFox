import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

import 'package_overview.dart';

/// Reads the package registry for one GitLab project.
class PackageRegistryRepository {
  PackageRegistryRepository(this._client);

  final GitLabClient _client;

  Future<void> deleteFile(int projectId, int packageId, int fileId) =>
      _client.packages.deleteFile(projectId, packageId, fileId);

  Future<void> delete(int projectId, int packageId) =>
      _client.packages.delete(projectId, packageId);

  Future<Paginated<GitLabPackage>> list(int projectId, {int page = 1}) =>
      _client.packages.list(projectId, page: page);

  Future<PackageOverview> load(int projectId, int packageId) async =>
      PackageOverview(
        package: await _client.packages.get(projectId, packageId),
        files: await files(projectId, packageId),
      );

  Future<Paginated<PackageFile>> files(
    int projectId,
    int packageId, {
    int page = 1,
  }) => _client.packages.listFiles(projectId, packageId, page: page);
}
