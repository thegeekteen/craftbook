import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/confirm_dialog.dart';

/// Settings page — backup, import, navigation, app info
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _SectionHeader('Backup'),
          const SizedBox(height: 8),
          _SettingsCard(
            icon: Icons.upload_outlined,
            title: 'Export backup',
            subtitle: 'Save database file to your device',
            onTap: () => BackupService.exportDatabase(context),
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            icon: Icons.download_outlined,
            title: 'Import backup',
            subtitle: 'Restore from a database file',
            onTap: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Import backup?',
                message:
                    'This will replace all current data with the backup. '
                    'You will need to restart the app after importing.',
                confirmText: 'Import',
                isDestructive: true,
              );
              if (confirmed && context.mounted) {
                await BackupService.importDatabase(context);
              }
            },
          ),
          const SizedBox(height: 24),
          _SectionHeader('Navigation'),
          const SizedBox(height: 8),
          _SettingsCard(
            icon: Icons.inventory_2_outlined,
            title: 'Products',
            subtitle: 'Manage products and BOM recipes',
            onTap: () => context.push(RouteNames.products),
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            icon: Icons.store_outlined,
            title: 'Channels & fees',
            subtitle: 'Configure sales channel fee rates',
            onTap: () => context.push(RouteNames.channels),
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            icon: Icons.shopping_cart_outlined,
            title: 'What to buy',
            subtitle: 'Low stock materials and blocked products',
            onTap: () => context.push(RouteNames.buyList),
          ),
          const SizedBox(height: 24),
          _SectionHeader('About'),
          const SizedBox(height: 8),
          Card(
            color: AppColors.paperHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
              side: const BorderSide(color: AppColors.hair),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: AppTextStyles.displaySmall
                        .copyWith(color: AppColors.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Offline-first order & material tracker for craft businesses.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.monoSection,
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.paperHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
        side: const BorderSide(color: AppColors.hair),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
