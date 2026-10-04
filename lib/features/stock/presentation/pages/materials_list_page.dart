import 'package:flutter/material.dart' hide Material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/material.dart';
import '../bloc/materials_bloc.dart';
import '../bloc/materials_event.dart';
import '../bloc/materials_state.dart';
import '../widgets/material_card.dart';

enum _StockFilter { all, low, promised }

/// Every material with its pips; filter by low or promised.
class MaterialsListPage extends StatelessWidget {
  const MaterialsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MaterialsBloc>()..add(const LoadMaterials()),
      child: const _MaterialsListView(),
    );
  }
}

class _MaterialsListView extends StatefulWidget {
  const _MaterialsListView();

  @override
  State<_MaterialsListView> createState() => _MaterialsListViewState();
}

class _MaterialsListViewState extends State<_MaterialsListView> {
  _StockFilter _filter = _StockFilter.all;
  String _query = '';
  List<Material> _materials = [];

  void _reload() => context.read<MaterialsBloc>().add(const LoadMaterials());

  Future<void> _open(String location) async {
    final changed = await context.push<bool>(location);
    if (changed == true && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lowCount = _materials.where((m) => m.isLowStock).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              onPressed: () => _open(RouteNames.buyList),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              icon: Icon(Icons.shopping_basket_outlined,
                  size: 17, color: lowCount > 0 ? c.alert : c.muted),
              label: Text(lowCount > 0 ? 'Buy list · $lowCount' : 'Buy list'),
            ),
          ),
        ],
      ),
      body: BlocConsumer<MaterialsBloc, MaterialsState>(
        listener: (context, state) {
          if (state is MaterialsError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          // The list stays visible while other events (e.g. errors) arrive.
          if (state is MaterialsLoaded) _materials = state.materials;
          if (state is MaterialsLoading || state is MaterialsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MaterialsError && _materials.isEmpty) {
            return Center(
                child: ErrorState(message: state.message, onRetry: _reload));
          }
          return _buildList();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(RouteNames.newMaterial),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Material'),
      ),
    );
  }

  Widget _buildList() {
    final searched = _query.isEmpty
        ? _materials
        : _materials
            .where((m) => m.name.toLowerCase().contains(_query))
            .toList();
    bool passes(Material m) => switch (_filter) {
          _StockFilter.all => true,
          _StockFilter.low => m.isLowStock,
          _StockFilter.promised => m.quantityPromised > 0,
        };
    final visible = searched.where(passes).toList()
      // Low stock first so problems surface without filtering.
      ..sort((a, b) {
        if (a.isLowStock != b.isLowStock) return a.isLowStock ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: AppSearchField(
            hint: 'Search materials',
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: ChoiceChipRow<_StockFilter>.single(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            selected: _filter,
            onSelected: (f) => setState(() => _filter = f),
            options: [
              ChipOption(_StockFilter.all, 'All', count: searched.length),
              ChipOption(_StockFilter.low, 'Low',
                  count: searched.where((m) => m.isLowStock).length),
              ChipOption(_StockFilter.promised, 'Promised',
                  count: searched.where((m) => m.quantityPromised > 0).length),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: visible.isEmpty
                ? ListView(children: [_empty()])
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        16, 4, 16, AppSpacing.fabClearance),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => MaterialCard(
                      material: visible[i],
                      onTap: () =>
                          _open(RouteNames.materialPath(visible[i].id!)),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _empty() {
    if (_materials.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No materials yet',
        message: 'Add the beads, yarn and boxes your products are made from.',
        actionLabel: 'Add material',
        onAction: () => _open(RouteNames.newMaterial),
      );
    }
    if (_query.isNotEmpty) {
      return EmptyState(
          icon: Icons.search_off_rounded,
          title: 'No matches',
          message: 'Nothing matches "$_query".');
    }
    return switch (_filter) {
      _StockFilter.low => const EmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: 'Nothing is low',
          message: 'Every material is above its reorder level.',
        ),
      _ => const EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Nothing promised',
          message: 'Materials reserved by open orders show up here.',
        ),
    };
  }
}
