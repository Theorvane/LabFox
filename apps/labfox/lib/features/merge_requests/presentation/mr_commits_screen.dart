import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/merge_requests_controllers.dart';
import 'controllers/mr_commits_controller.dart';

/// Lists complete MR commit membership and navigates by identifiers only.
class MrCommitsScreen extends ConsumerWidget {
  const MrCommitsScreen({
    required this.projectId,
    required this.iid,
    super.key,
  });
  final int projectId, iid;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final resource = MergeRequestRef(projectId: projectId, iid: iid);
    final provider = mrCommitsControllerProvider(resource);
    return Scaffold(
      appBar: AppBar(title: Text(l.commitsTitle)),
      body: ref
          .watch(provider)
          .when(
            skipLoadingOnRefresh: false,
            skipLoadingOnReload: false,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.commitsError),
                  TextButton(
                    onPressed: () {
                      ref.invalidate(
                        mrCommitOriginControllerProvider(resource),
                      );
                      ref.invalidate(provider);
                    },
                    child: Text(l.retry),
                  ),
                ],
              ),
            ),
            data: (commits) {
              if (commits == null) {
                return Center(child: Text(l.mrReviewUnavailable));
              }
              if (commits.isEmpty) return Center(child: Text(l.mrCommitsEmpty));
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: LabFoxBreakpoints.desktop,
                  ),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(
                        mrCommitOriginControllerProvider(resource),
                      );
                      ref.invalidate(provider);
                      try {
                        await ref.read(provider.future);
                      } catch (_) {
                        /* The provider displays a sanitized read error. */
                      }
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: commits.length,
                      itemBuilder: (_, i) {
                        final c = commits[i];
                        final canonical = RegExp(
                          r'^[0-9a-f]{40}$',
                        ).hasMatch(c.id);
                        return ListTile(
                          title: Text(
                            c.title.isEmpty ? c.id : c.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            canonical ? c.id.substring(0, 8) : c.id,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: canonical
                              ? () => context.push(
                                  Routes.mergeRequestCommitChanges(
                                    projectId,
                                    iid,
                                    c.id,
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}
