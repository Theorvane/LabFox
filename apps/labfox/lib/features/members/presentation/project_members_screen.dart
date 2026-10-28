import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitlab_models/gitlab_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/members_controller.dart';

/// Effective project or group members, including inherited and shared access.
class ProjectMembersScreen extends ConsumerStatefulWidget {
  const ProjectMembersScreen({this.projectId, this.groupId, super.key})
    : assert((projectId == null) != (groupId == null));

  final int? projectId;
  final int? groupId;

  @override
  ConsumerState<ProjectMembersScreen> createState() =>
      _ProjectMembersScreenState();
}

/// Group-flavored entry point that reuses the member list presentation.
class GroupMembersScreen extends ProjectMembersScreen {
  const GroupMembersScreen({required int groupId, super.key})
    : super(groupId: groupId);
}

class _ProjectMembersScreenState extends ConsumerState<ProjectMembersScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = MemberListRef(
      projectId: widget.projectId,
      groupId: widget.groupId,
      query: _query,
    );
    final members = ref.watch(projectMembersControllerProvider(key));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupId == null
              ? l10n.projectMembersTitle
              : l10n.groupMembersTitle,
        ),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(
                  widget.groupId == null
                      ? Routes.projectOverview(widget.projectId!)
                      : Routes.group(widget.groupId!),
                ),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.all(LabFoxSpacing.md),
                child: TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LabFoxIcons.search),
                    hintText: widget.groupId == null
                        ? l10n.projectMembersSearch
                        : l10n.groupMembersSearch,
                    border: const OutlineInputBorder(),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.projectMembersClearSearch,
                            icon: const Icon(LabFoxIcons.close),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (value) => setState(() => _query = value.trim()),
                ),
              ),
            ),
          ),
          Expanded(
            child: members.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.groupId == null
                          ? l10n.projectMembersError
                          : l10n.groupMembersError,
                    ),
                    const SizedBox(height: LabFoxSpacing.md),
                    FilledButton(
                      onPressed: () =>
                          ref.invalidate(projectMembersControllerProvider(key)),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (page) => page.items.isEmpty
                  ? Center(
                      child: Text(
                        widget.groupId == null
                            ? l10n.projectMembersEmpty
                            : l10n.groupMembersEmpty,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.refresh(
                        projectMembersControllerProvider(key).future,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final wide =
                              constraints.maxWidth >= LabFoxBreakpoints.tablet;
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 900,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      LabFoxSpacing.md,
                                    ),
                                    child: Card.outlined(
                                      margin: EdgeInsets.zero,
                                      child: Column(
                                        children: [
                                          for (final member in page.items)
                                            _MemberRow(
                                              member: member,
                                              wide: wide,
                                            ),
                                          if (page.hasMore)
                                            TextButton(
                                              onPressed: () => ref
                                                  .read(
                                                    projectMembersControllerProvider(
                                                      key,
                                                    ).notifier,
                                                  )
                                                  .loadMore(),
                                              child: Text(
                                                l10n.projectMembersLoadMore,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.wide});

  final ProjectMember member;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final role = _roleLabel(l10n, member.accessLevel);
    final expiry = member.expiresAt == null
        ? null
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toString(),
          ).format(member.expiresAt!);
    final avatar = UserAvatar(
      user: User(
        id: member.id,
        username: member.username,
        name: member.name,
        avatarUrl: member.avatarUrl,
      ),
      radius: 18,
    );
    if (!wide) {
      return ListTile(
        leading: avatar,
        title: Text(member.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${member.username}'),
            Text(role),
            if (expiry != null)
              Wrap(
                spacing: LabFoxSpacing.xs,
                children: [Text(l10n.projectMembersExpiry), Text(expiry)],
              ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(LabFoxSpacing.md),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: LabFoxSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text('@${member.username}'),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(role)),
          Expanded(
            child: expiry == null
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(l10n.projectMembersExpiry), Text(expiry)],
                  ),
          ),
        ],
      ),
    );
  }
}

String _roleLabel(AppLocalizations l10n, int accessLevel) =>
    switch (accessLevel) {
      0 => l10n.memberRoleNoAccess,
      5 => l10n.memberRoleMinimal,
      10 => l10n.memberRoleGuest,
      15 => l10n.memberRolePlanner,
      20 => l10n.memberRoleReporter,
      25 => l10n.memberRoleSecurityManager,
      30 => l10n.memberRoleDeveloper,
      40 => l10n.memberRoleMaintainer,
      50 => l10n.memberRoleOwner,
      _ => l10n.memberRoleUnknown,
    };
