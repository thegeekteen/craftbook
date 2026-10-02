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

class _MaterialsListView extends StatelessWidget {
  const _MaterialsListView();

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
            }
          },
          builder: (context, state) {
            return TabBarView(
              children: [
                _buildTab(context, state, _MaterialsTabFilter.all),
                _buildTab(context, state, _MaterialsTabFilter.low),
                _buildTab(context, state, _MaterialsTabFilter.promised),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.showSnackBar('Add material — coming soon');
          },
          backgroundColor: AppColors.success,
          child: const Icon(Icons.add, color: Colors.white),
        ),
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
              onTap: () => context.push(
                RouteNames.materialDetail
                    .replaceFirst(':id', '${material.id}'),
              ),
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
