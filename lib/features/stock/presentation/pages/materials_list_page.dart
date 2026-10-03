import 'package:flutter/material.dart' hide Material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/material.dart';
import '../bloc/materials_bloc.dart';
import '../bloc/materials_event.dart';
import '../bloc/materials_state.dart';
import '../widgets/material_card.dart';

/// Materials list page — Flow 4: Stock management
class MaterialsListPage extends StatelessWidget {
  const MaterialsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MaterialsBloc>()..add(LoadMaterials()),
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
  String _searchQuery = '';

  static const _tabs = ['All', 'Low', 'Promised'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Materials',
            style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, size: 20),
              onPressed: () => context.push(RouteNames.buyList),
            ),
          ],
          bottom: TabBar(
            labelColor: AppColors.success,
            unselectedLabelColor: AppColors.muted,
            indicatorColor: AppColors.success,
            labelStyle: AppTextStyles.monoLabel,
            tabs: _tabs.map((t) => Tab(text: t.toUpperCase())).toList(),
          ),
        ),
        body: BlocConsumer<MaterialsBloc, MaterialsState>(
          listener: (context, state) {
            if (state is MaterialsError) {
              context.showSnackBar(state.message, isError: true);
            } else if (state is MaterialCreated) {
              context.showSnackBar('Material added');
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search materials...',
                      prefixIcon:
                          const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  size: 18),
                              onPressed: () => setState(
                                  () => _searchQuery = ''),
                            )
                          : null,
                      isDense: true,
                    ),
                    onChanged: (v) =>
                        setState(() => _searchQuery = v),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTab(context, state,
                          _MaterialsTabFilter.all),
                      _buildTab(context, state,
                          _MaterialsTabFilter.low),
                      _buildTab(context, state,
                          _MaterialsTabFilter.promised),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddMaterialDialog(context),
          backgroundColor: AppColors.success,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _showAddMaterialDialog(BuildContext context) {
    final nameController = TextEditingController();
    final packSizeController = TextEditingController();
    final packPriceController = TextEditingController();
    final alertLevelController = TextEditingController(text: '5');
    final supplierController = TextEditingController();
    final initialQtyController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.paperHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('New material',
            style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Material name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: packSizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pack size (pcs)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: packPriceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Pack price',
                  prefixText: '₱ ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: alertLevelController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Alert level (pcs)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: supplierController,
                decoration: const InputDecoration(
                  labelText: 'Supplier (optional)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: initialQtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Initial quantity (pcs)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final packSize =
                  int.tryParse(packSizeController.text) ?? 0;
              final packPrice =
                  double.tryParse(packPriceController.text) ?? 0;
              final alertLevel =
                  int.tryParse(alertLevelController.text) ?? 5;
              final supplier = supplierController.text.trim();
              final initialQty =
                  int.tryParse(initialQtyController.text) ?? 0;

              if (name.isEmpty) {
                context.showSnackBar('Name is required',
                    isError: true);
                return;
              }
              if (packSize <= 0) {
                context.showSnackBar('Pack size must be > 0',
                    isError: true);
                return;
              }
              if (packPrice <= 0) {
                context.showSnackBar('Pack price must be > 0',
                    isError: true);
                return;
              }

              Navigator.pop(ctx);
              context.read<MaterialsBloc>().add(CreateMaterialEvent(
                    name: name,
                    packSize: packSize,
                    packPrice: packPrice,
                    alertLevel: alertLevel,
                    supplier:
                        supplier.isEmpty ? null : supplier,
                    initialQuantity: initialQty,
                  ));
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
      BuildContext context, MaterialsState state, _MaterialsTabFilter filter) {
    if (state is MaterialsLoading || state is MaterialsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MaterialsLoaded) {
      List<Material> materials = state.materials;

      switch (filter) {
        case _MaterialsTabFilter.low:
          materials = materials.where((m) => m.isLowStock).toList();
          break;
        case _MaterialsTabFilter.promised:
          materials =
              materials.where((m) => m.quantityPromised > 0).toList();
          break;
        case _MaterialsTabFilter.all:
          break;
      }

      if (_searchQuery.isNotEmpty) {
        materials = materials.where((m) =>
            m.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      }

      if (materials.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined,
                  color: AppColors.muted, size: 48),
              const SizedBox(height: 12),
              Text(
                'No materials here',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.muted),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<MaterialsBloc>().add(LoadMaterials());
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final material = materials[index];
            return MaterialCard(
              material: material,
              onTap: () async {
                final result = await context.push<bool>(
                  RouteNames.materialDetail
                      .replaceFirst(':id', '${material.id}'),
                );
                if (result == true && context.mounted) {
                  context.read<MaterialsBloc>().add(const LoadMaterials());
                }
              },
            );
          },
        ),
      );
    }

    if (state is MaterialsError) {
      return Center(
        child: Text(state.message,
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.alert)),
      );
    }

    return const SizedBox.shrink();
  }
}

enum _MaterialsTabFilter { all, low, promised }
