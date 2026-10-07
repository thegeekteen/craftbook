import 'package:flutter/material.dart' hide Material;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/filter_controls.dart';
import '../../domain/entities/material.dart';
import '../bloc/materials_bloc.dart';
import '../bloc/materials_state.dart';
import '../material_list_filter.dart';
import 'material_actions.dart';
import 'material_card.dart';

/// The Materials tab of Inventory: every material with its pips. The
/// page owns the search and filter so its app bar can open the filter
/// sheet; this draws the list and the active chip.
class MaterialsTab extends StatefulWidget {
  final TextEditingController search;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final MaterialStockFilter filter;
  final ValueChanged<MaterialStockFilter> onFilterChanged;

  /// Pushes [location] and reloads when it reports a change.
  final Future<void> Function(String location) onOpen;

  /// Reloads the catalogue, e.g. after a long-press action.
  final VoidCallback onReload;

  const MaterialsTab({
    super.key,
    required this.search,
    required this.query,
    required this.onQueryChanged,
    required this.filter,
    required this.onFilterChanged,
    required this.onOpen,
    required this.onReload,
  });

  @override
  State<MaterialsTab> createState() => _MaterialsTabState();
}

class _MaterialsTabState extends State<MaterialsTab>
    with AutomaticKeepAliveClientMixin {
  List<Material> _materials = [];

  // Keeps the scroll position while the Products tab is showing.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: AppSearchField(
            hint: context.l10n.stockSearchHint,
            controller: widget.search,
            onChanged: widget.onQueryChanged,
          ),
        ),
        Expanded(
          child: BlocConsumer<MaterialsBloc, MaterialsState>(
            listener: (context, state) {
              if (state is MaterialsError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              // The list stays visible while other events (e.g. errors)
              // arrive.
              if (state is MaterialsLoaded) _materials = state.materials;
              if (state is MaterialsLoading || state is MaterialsInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is MaterialsError && _materials.isEmpty) {
                return Center(
                    child: ErrorState(
                        message: state.message, onRetry: widget.onReload));
              }
              return _buildList();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    final view =
        MaterialCatalogueView(materials: _materials, query: widget.query);
    final filter = view.effective(widget.filter);
    final visible = view.apply(filter);

    return Column(
      children: [
        ActiveFilterChips(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          filters: [
            if (filter != MaterialStockFilter.any)
              (
                filter.label(context.l10n),
                () => widget.onFilterChanged(MaterialStockFilter.any),
              ),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => widget.onReload(),
            child: visible.isEmpty
                ? ListView(children: [_empty(filter)])
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        16, 4, 16, AppSpacing.fabClearance),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => MaterialCard(
                      material: visible[i],
                      onTap: () => widget
                          .onOpen(RouteNames.materialPath(visible[i].id!)),
                      onLongPress: () async {
                        if (await MaterialActions.open(context, visible[i]) &&
                            mounted) {
                          widget.onReload();
                        }
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _empty(MaterialStockFilter filter) {
    final l10n = context.l10n;
    if (_materials.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: l10n.stockEmptyNoneTitle,
        message: l10n.stockEmptyNoneMessage,
        actionLabel: l10n.stockAddMaterial,
        onAction: () => widget.onOpen(RouteNames.newMaterial),
      );
    }
    if (widget.query.trim().isNotEmpty) {
      return EmptyState(
          icon: Icons.search_off_rounded,
          title: l10n.stockEmptyNoMatchTitle,
          message: l10n.stockEmptyNoMatchMessage(widget.query.trim()));
    }
    return switch (filter) {
      MaterialStockFilter.any => EmptyState(
          icon: Icons.archive_outlined,
          title: l10n.stockEmptyAllArchivedTitle,
          message: l10n.stockEmptyAllArchivedMessage,
        ),
      MaterialStockFilter.low => EmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: l10n.stockEmptyNotLowTitle,
          message: l10n.stockEmptyNotLowMessage,
        ),
      _ => EmptyState(
          icon: Icons.inventory_2_outlined,
          title: l10n.stockEmptyNoPromisedTitle,
          message: l10n.stockEmptyNoPromisedMessage,
        ),
    };
  }
}
