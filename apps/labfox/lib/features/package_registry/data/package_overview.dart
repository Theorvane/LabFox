import 'package:gitlab_api/gitlab_api.dart';
import 'package:gitlab_models/gitlab_models.dart';

/// A package and the loaded pages of its files.
class PackageOverview {
  const PackageOverview({required this.package, required this.files});

  final GitLabPackage package;
  final Paginated<PackageFile> files;

  PackageOverview withFiles(Paginated<PackageFile> value) =>
      PackageOverview(package: package, files: value);
}
