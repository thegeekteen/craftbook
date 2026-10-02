import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/route_names.dart';
import '../theme/colors.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(
        currentIndex: _calculateSelectedIndex(context),
        onTabSelected: (index) => _onTabSelected(context, index),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == RouteNames.today) return 0;
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/materials') || location.startsWith('/stock')) return 2;
    if (location.startsWith('/earnings')) return 3;
    if (location.startsWith('/settings') ||
        location.startsWith('/products') ||
        location.startsWith('/channels')) return 4;
    return 0;
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.today);
      case 1:
        context.go(RouteNames.orders);
      case 2:
        context.go(RouteNames.materials);
      case 3:
        context.go(RouteNames.earnings);
      case 4:
        context.go(RouteNames.settings);
    }
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const _BottomNav({
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paperHigh,
        border: Border(top: BorderSide(color: AppColors.hair)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Today',
                isSelected: currentIndex == 0,
                onTap: () => onTabSelected(0),
              ),
              _NavItem(
                icon: Icons.layers_outlined,
                activeIcon: Icons.layers,
                label: 'Orders',
                isSelected: currentIndex == 1,
                onTap: () => onTabSelected(1),
              ),
              _NavItem(
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: 'Stock',
                isSelected: currentIndex == 2,
                onTap: () => onTabSelected(2),
              ),
              _NavItem(
                icon: Icons.monetization_on_outlined,
                activeIcon: Icons.monetization_on,
                label: 'Money',
                isSelected: currentIndex == 3,
                onTap: () => onTabSelected(3),
              ),
              _NavItem(
                icon: Icons.more_horiz,
                activeIcon: Icons.more_horiz,
                label: 'More',
                isSelected: currentIndex == 4,
                onTap: () => onTabSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? AppColors.success : AppColors.muted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                fontFamily: 'IBMPlexSans',
                color: isSelected ? AppColors.success : AppColors.muted,
                letterSpacing: 0.02,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
