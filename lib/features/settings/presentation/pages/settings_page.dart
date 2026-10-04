import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../notes/domain/repositories/note_repository.dart';
import '../../../order_fields/domain/repositories/order_field_repository.dart';
import '../../../products/domain/repositories/channel_repository.dart';
import '../../../social_links/domain/repositories/social_link_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../../../updates/presentation/bloc/update_cubit.dart';
import '../../../updates/presentation/bloc/update_state.dart';
import '../../../updates/presentation/widgets/update_row.dart';
import '../widgets/appearance_card.dart';

/// More: the catalogue (materials, channels, order fields, buy list), the
/// notebook and your data.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _materialsHint;
  String? _channelsHint;
  String? _orderFieldsHint;
  String? _buyListHint;
  String? _notesHint;
  String? _socialHint;
  bool _canUndoRestore = false;

  @override
  void initState() {
    super.initState();
    _loadHints();
  }

  /// Live one-liners under each row. Failures just leave the default text.
  Future<void> _loadHints() async {
    final materials = await getIt<MaterialRepository>().getAllMaterials();
    final channels = await getIt<ChannelRepository>().getAllChannels();
    final buyList = await getIt<MaterialRepository>().getBuyList();
    final orderFields = await getIt<OrderFieldRepository>().getFields();
    final notes = await getIt<NoteRepository>().getNotes();
    final social = await getIt<SocialLinkRepository>().getLinks();
    final canUndoRestore = await BackupService.canUndoRestore();
    if (!mounted) return;
    setState(() {
      _canUndoRestore = canUndoRestore;
      if (materials case Success(:final value)) {
        final listed = value.where((m) => !m.isArchived).toList();
        final low = listed.where((m) => m.isLowStock).length;
        _materialsHint =
            '${listed.length} ${listed.length == 1 ? 'material' : 'materials'}'
            '${low > 0 ? ' · $low low' : ''}';
      }
      if (channels case Success(:final value)) {
        final on = value.where((c) => c.isActive).length;
        final off = value.length - on;
        _channelsHint = '$on on${off > 0 ? ' · $off off' : ''}';
      }
      if (orderFields case Success(:final value)) {
        final archived = value.where((f) => f.isArchived).length;
        final active = value.length - archived;
        _orderFieldsHint = value.isEmpty
            ? null
            : '$active ${active == 1 ? 'field' : 'fields'}'
                '${archived > 0 ? ' · $archived archived' : ''}';
      }
      if (buyList case Success(:final value)) {
        final total = value.fold<double>(0, (s, i) => s + i.totalCost);
        _buyListHint = value.isEmpty
            ? 'Nothing to buy'
            : '${value.length} ${value.length == 1 ? 'item' : 'items'} · ${CurrencyFormatter.format(total)}';
      }
      if (notes case Success(:final value)) {
        final pinned = value.where((n) => n.isPinned).length;
        _notesHint = value.isEmpty
            ? null
            : '${value.length} ${value.length == 1 ? 'note' : 'notes'}'
                '${pinned > 0 ? ' · $pinned pinned' : ''}';
      }
      if (social case Success(:final value)) {
        _socialHint = value.isEmpty
            ? null
            : '${value.length} ${value.length == 1 ? 'shortcut' : 'shortcuts'} · '
                '${value.take(3).map((l) => l.label).join(', ')}';
      }
    });
  }

  Future<void> _open(String location) async {
    await context.push(location);
    if (mounted) _loadHints();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return BlocProvider(
      create: (_) => getIt<UpdateCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('More')),
        body: ListView(
          padding: AppSpacing.page,
          children: [
            const SectionLabel('Catalogue',
                padding: EdgeInsets.fromLTRB(2, 4, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                _MoreRow(
                  icon: Icons.inventory_2_outlined,
                  title: 'Materials',
                  subtitle:
                      _materialsHint ?? 'What your products are made from',
                  onTap: () => _open(RouteNames.materials),
                ),
                _MoreRow(
                  icon: Icons.storefront_outlined,
                  title: 'Channels & fees',
                  subtitle:
                      _channelsHint ?? 'Where you sell and what they charge',
                  onTap: () => _open(RouteNames.channels),
                ),
                _MoreRow(
                  icon: Icons.dashboard_customize_outlined,
                  title: 'Order fields',
                  subtitle:
                      _orderFieldsHint ?? 'Extra details to note on each order',
                  onTap: () => _open(RouteNames.orderFields),
                ),
                _MoreRow(
                  icon: Icons.shopping_basket_outlined,
                  title: 'Buy list',
                  subtitle: _buyListHint ?? 'Things to restock',
                  onTap: () => _open(RouteNames.buyList),
                ),
              ]),
            ),
            const SectionLabel('Notebook',
                padding: EdgeInsets.fromLTRB(2, 20, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                _MoreRow(
                  icon: Icons.sticky_note_2_outlined,
                  title: 'Notes',
                  subtitle: _notesHint ?? 'Supplier details, ideas, how-tos',
                  onTap: () => _open(RouteNames.notes),
                ),
              ]),
            ),
            const SectionLabel('Your shop online',
                padding: EdgeInsets.fromLTRB(2, 20, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                _MoreRow(
                  icon: Icons.share_outlined,
                  title: 'Social shortcuts',
                  subtitle: _socialHint ?? 'Facebook, TikTok, Shopee, Lazada…',
                  onTap: () => _open(RouteNames.socialLinks),
                ),
              ]),
            ),
            const SectionLabel('Appearance',
                padding: EdgeInsets.fromLTRB(2, 20, 2, 0)),
            const SizedBox(height: 8),
            const AppearanceCard(),
            const SectionLabel('Your data',
                padding: EdgeInsets.fromLTRB(2, 20, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                _MoreRow(
                  icon: Icons.upload_rounded,
                  title: 'Export backup',
                  subtitle: 'Save a copy of everything to a file',
                  onTap: () => BackupService.exportDatabase(context),
                ),
                _MoreRow(
                  icon: Icons.download_rounded,
                  iconColor: c.alert,
                  title: 'Restore from backup',
                  subtitle: 'Replaces everything on this phone',
                  onTap: () => BackupService.importDatabase(context),
                ),
                if (_canUndoRestore)
                  _MoreRow(
                    icon: Icons.undo_rounded,
                    title: 'Undo last restore',
                    subtitle: 'Go back to the data from before it',
                    onTap: () => BackupService.undoRestore(context),
                  ),
              ]),
            ),
            const SectionLabel('About',
                padding: EdgeInsets.fromLTRB(2, 20, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                _MoreRow(
                  icon: Icons.info_outline_rounded,
                  title: 'About Craftbook',
                  subtitle: 'What it does and how to use it',
                  onTap: () => _open(RouteNames.about),
                ),
                const UpdateRow(),
              ]),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  const AppLogo(size: 64),
                  const SizedBox(height: 10),
                  Text(
                    AppConstants.appName,
                    style: AppTextStyles.displaySmall
                        .copyWith(color: c.ink, fontSize: 17),
                  ),
                  const SizedBox(height: 2),
                  BlocSelector<UpdateCubit, UpdateState, String?>(
                    selector: (state) => state.currentVersion,
                    builder: (context, version) => Text(
                      '${version == null ? '' : 'Version $version · '}'
                      'all data stays on this phone',
                      style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MoreRow({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CardRow(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration:
            BoxDecoration(color: c.paper, borderRadius: AppRadii.controlAll),
        child: Icon(icon, size: 20, color: iconColor ?? c.ink),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right_rounded, color: c.muted),
    );
  }
}
