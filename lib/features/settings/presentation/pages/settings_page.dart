import 'package:flutter/foundation.dart' show kDebugMode;
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
import '../../../../core/widgets/more_row.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../debug/presentation/widgets/debug_section.dart';
import '../../../notes/domain/repositories/note_repository.dart';
import '../../../order_fields/domain/repositories/order_field_repository.dart';
import '../../../products/domain/repositories/channel_repository.dart';
import '../../../social_links/domain/repositories/social_link_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../../../updates/presentation/bloc/update_cubit.dart';
import '../../../updates/presentation/bloc/update_state.dart';
import '../../../updates/presentation/widgets/update_row.dart';
import '../../../discounts/domain/repositories/discount_preset_repository.dart';
import '../../../units/domain/repositories/unit_repository.dart';
import '../../../orders/domain/usecases/get_receivables.dart';
import '../../domain/entities/tax_settings.dart';
import '../bloc/currency_cubit.dart';
import '../bloc/tax_settings_cubit.dart';
import '../widgets/appearance_card.dart';
import '../widgets/currency_sheet.dart';
import '../widgets/tax_sheet.dart';

/// More: the shop's setup (channels, order fields, units, buy list), the
/// notebook and your data. Materials live on the Inventory tab.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _channelsHint;
  String? _orderFieldsHint;
  String? _buyListHint;
  String? _notesHint;
  String? _socialHint;
  String? _discountsHint;
  String? _receivablesHint;
  String? _unitsHint;
  bool _canUndoRestore = false;

  @override
  void initState() {
    super.initState();
    _loadHints();
  }

  /// Live one-liners under each row. Failures just leave the default text.
  Future<void> _loadHints() async {
    final channels = await getIt<ChannelRepository>().getAllChannels();
    final buyList = await getIt<MaterialRepository>().getBuyList();
    final orderFields = await getIt<OrderFieldRepository>().getFields();
    final notes = await getIt<NoteRepository>().getNotes();
    final social = await getIt<SocialLinkRepository>().getLinks();
    final discounts = await getIt<DiscountPresetRepository>().getPresets();
    final units = await getIt<UnitRepository>().getUnits();
    final receivables = await getIt<GetReceivables>()();
    final canUndoRestore = await BackupService.canUndoRestore();
    if (!mounted) return;
    setState(() {
      _canUndoRestore = canUndoRestore;
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
      if (receivables case Success(:final value)) {
        _receivablesHint = value.isEmpty
            ? null
            : '${CurrencyFormatter.format(value.total)} · '
                '${value.orderCount} ${value.orderCount == 1 ? 'order' : 'orders'}';
      }
      if (discounts case Success(:final value)) {
        _discountsHint =
            value.isEmpty ? null : value.take(3).map((d) => d.label).join(', ');
      }
      if (units case Success(:final value) when value.isNotEmpty) {
        // The default is the flagged one, or the first in the list.
        var startsOn = value.first.label;
        for (final u in value) {
          if (u.isDefault) startsOn = u.label;
        }
        _unitsHint = '${value.length} · new items start on $startsOn';
      }
      if (social case Success(:final value)) {
        _socialHint = value.isEmpty
            ? null
            : '${value.length} ${value.length == 1 ? 'shortcut' : 'shortcuts'} · '
                '${value.take(3).map((l) => l.label).join(', ')}';
      }
    });
  }

  Future<void> _pickCurrency() async {
    final cubit = getIt<CurrencyCubit>();
    final picked = await showCurrencySheet(context, current: cubit.state);
    if (picked == null) return;
    await cubit.set(picked);
    // Hints carry amounts, so redraw them in the new symbol.
    if (mounted) _loadHints();
  }

  static String _taxHint(TaxSettings tax) {
    if (!tax.enabled) return 'Off';
    final rate = tax.rate == tax.rate.roundToDouble()
        ? tax.rate.toStringAsFixed(0)
        : '${tax.rate}';
    return '${tax.label} $rate% · ${tax.inclusive ? 'in prices' : 'added on top'}'
        '${tax.onByDefault ? '' : ' · off by default'}';
  }

  Future<void> _editTax() async {
    final cubit = getIt<TaxSettingsCubit>();
    final picked = await showTaxSheet(context, current: cubit.state);
    if (picked == null) return;
    await cubit.set(picked);
    if (mounted) setState(() {});
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
            const SectionLabel('Notebook',
                padding: EdgeInsets.fromLTRB(2, 2, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                MoreRow(
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
                MoreRow(
                  icon: Icons.share_outlined,
                  title: 'Social shortcuts',
                  subtitle: _socialHint ?? 'Facebook, TikTok, Shopee, Lazada…',
                  onTap: () => _open(RouteNames.socialLinks),
                ),
              ]),
            ),
            const SectionLabel('Catalogue',
                padding: EdgeInsets.fromLTRB(2, 20, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                MoreRow(
                  icon: Icons.storefront_outlined,
                  title: 'Channels & fees',
                  subtitle:
                      _channelsHint ?? 'Where you sell and what they charge',
                  onTap: () => _open(RouteNames.channels),
                ),
                MoreRow(
                  icon: Icons.dashboard_customize_outlined,
                  title: 'Order fields',
                  subtitle:
                      _orderFieldsHint ?? 'Extra details to note on each order',
                  onTap: () => _open(RouteNames.orderFields),
                ),
                MoreRow(
                  icon: Icons.square_foot_outlined,
                  title: 'Units of measure',
                  subtitle: _unitsHint ?? 'What you count things in',
                  onTap: () => _open(RouteNames.units),
                ),
                MoreRow(
                  icon: Icons.shopping_basket_outlined,
                  title: 'Buy list',
                  subtitle: _buyListHint ?? 'Things to restock',
                  onTap: () => _open(RouteNames.buyList),
                ),
              ]),
            ),
            const SectionLabel('Money & orders',
                padding: EdgeInsets.fromLTRB(2, 20, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                MoreRow(
                  icon: Icons.schedule_rounded,
                  title: 'Waiting for payment',
                  subtitle: _receivablesHint ?? 'Everyone has paid',
                  onTap: () => _open(RouteNames.receivables),
                ),
                MoreRow(
                  icon: Icons.currency_exchange_rounded,
                  title: 'Currency',
                  subtitle: CurrencyFormatter.currency.label,
                  onTap: _pickCurrency,
                ),
                MoreRow(
                  icon: Icons.account_balance_outlined,
                  title: 'Tax',
                  subtitle: _taxHint(getIt<TaxSettingsCubit>().state),
                  onTap: _editTax,
                ),
                MoreRow(
                  icon: Icons.local_offer_outlined,
                  title: 'Discounts',
                  subtitle: _discountsHint ?? 'Ones you give often',
                  onTap: () => _open(RouteNames.discounts),
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
                MoreRow(
                  icon: Icons.upload_rounded,
                  title: 'Export backup',
                  subtitle: 'Save a copy of everything to a file',
                  onTap: () => BackupService.exportDatabase(context),
                ),
                MoreRow(
                  icon: Icons.download_rounded,
                  iconColor: c.alert,
                  title: 'Restore from backup',
                  subtitle: 'Replaces everything on this phone',
                  onTap: () => BackupService.importDatabase(context),
                ),
                if (_canUndoRestore)
                  MoreRow(
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
                MoreRow(
                  icon: Icons.info_outline_rounded,
                  title: 'About Craftbook',
                  subtitle: 'What it does and how to use it',
                  onTap: () => _open(RouteNames.about),
                ),
                const UpdateRow(),
              ]),
            ),
            // Sample-data tools, so they can't exist in a shop owner's build.
            if (kDebugMode) const DebugSection(),
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
