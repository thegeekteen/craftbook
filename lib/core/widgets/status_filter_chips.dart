import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../../features/orders/domain/entities/order.dart';

/// Horizontal row of status filter chips with an "All" toggle.
class StatusFilterChips extends StatelessWidget {
  final Set<OrderStatus> selected;
  final ValueChanged<Set<OrderStatus>> onChanged;

  const StatusFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  bool get _isAll => selected.length == OrderStatus.values.length;

  void _toggle(OrderStatus status) {
    final next = Set<OrderStatus>.from(selected);
    if (next.contains(status)) {
      if (next.length > 1) next.remove(status);
    } else {
      next.add(status);
    }
    onChanged(next);
  }

  void _toggleAll() {
    if (_isAll) {
      onChanged({OrderStatus.pending});
    } else {
      onChanged(Set<OrderStatus>.from(OrderStatus.values));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip(
            label: 'All',
            isSelected: _isAll,
            onTap: _toggleAll,
            color: AppColors.ink,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Pending',
            isSelected: selected.contains(OrderStatus.pending),
            onTap: () => _toggle(OrderStatus.pending),
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Packed',
            isSelected: selected.contains(OrderStatus.packed),
            onTap: () => _toggle(OrderStatus.packed),
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Shipped',
            isSelected: selected.contains(OrderStatus.shipped),
            onTap: () => _toggle(OrderStatus.shipped),
            color: AppColors.coin,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Cancelled',
            isSelected: selected.contains(OrderStatus.cancelled),
            onTap: () => _toggle(OrderStatus.cancelled),
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : AppColors.paperHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.hair,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? color : AppColors.muted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
