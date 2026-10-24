import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import 'controllers/environments_controller.dart';

/// Project environments with state filtering and server-side search.
class EnvironmentsScreen extends ConsumerStatefulWidget {
  const EnvironmentsScreen({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<EnvironmentsScreen> createState() => _EnvironmentsScreenState();
}

class _EnvironmentsScreenState extends ConsumerState<EnvironmentsScreen> {
  String? _state;
  String? _search;
  String? _searchError;

  void _submitSearch(String input) {
    final value = input.trim();
    setState(() {
      if (value.isNotEmpty && value.length < 3) {
        _searchError = AppLocalizations.of(context).environmentsSearchLength;
      } else {
        _searchError = null;
        _search = value.isEmpty ? null : value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = EnvironmentListRef(
      projectId: widget.projectId,
      state: _state,
      search: _search,
    );
    final environments = ref.watch(environmentListControllerProvider(key));
    final filters = <(String?, String)>[
      (null, l10n.environmentsAll),
      ('available', l10n.environmentsAvailable),
      ('stopping', l10n.environmentsStopping),
      ('stopped', l10n.environmentsStopped),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.environmentsTitle),
        actions: [
          IconButton(
            icon: const Icon(LabFoxIcons.private),
            tooltip: l10n.protectedEnvironmentsTitle,
            onPressed: () =>
                context.push(Routes.protectedEnvironments(widget.projectId)),
          ),
        ],
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.projectOverview(widget.projectId)),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  LabFoxSpacing.md,
                  LabFoxSpacing.md,
                  LabFoxSpacing.md,
                  0,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LabFoxIcons.search),
                    hintText: l10n.environmentsSearch,
                    errorText: _searchError,
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: _submitSearch,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LabFoxSpacing.md,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: LabFoxSpacing.sm),
                  itemBuilder: (context, index) {
                    final filter = filters[index];
                    return ChoiceChip(
                      label: Text(filter.$2),
                      selected: _state == filter.$1,
                      onSelected: (_) => setState(() => _state = filter.$1),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: environments.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.environmentsError),
                    const SizedBox(height: LabFoxSpacing.md),
                    FilledButton(
                      onPressed: () => ref.invalidate(
                        environmentListControllerProvider(key),
                      ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (page) => page.items.isEmpty
                  ? Center(child: Text(l10n.environmentsEmpty))
                  : RefreshIndicator(
                      onRefresh: () => ref.refresh(
                        environmentListControllerProvider(key).future,
                      ),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 900),
                              child: Padding(
                                padding: const EdgeInsets.all(LabFoxSpacing.md),
                                child: Card.outlined(
                                  margin: EdgeInsets.zero,
                                  child: Column(
                                    children: [
                                      for (final environment in page.items)
                                        ListTile(
                                          leading: const Icon(
                                            LabFoxIcons.environment,
                                          ),
                                          title: Text(environment.name),
                                          subtitle: Text(environment.state),
                                          trailing: const Icon(
                                            LabFoxIcons.chevron,
                                          ),
                                          onTap: () => context.push(
                                            Routes.environment(
                                              widget.projectId,
                                              environment.id,
                                            ),
                                          ),
                                        ),
                                      if (page.hasMore)
                                        TextButton(
                                          onPressed: () => ref
                                              .read(
                                                environmentListControllerProvider(
                                                  key,
                                                ).notifier,
                                              )
                                              .loadMore(),
                                          child: Text(
                                            l10n.environmentsLoadMore,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
