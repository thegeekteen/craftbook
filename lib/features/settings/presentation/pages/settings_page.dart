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
import '../../../../core/utils/l10n_extension.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/currency_cubit.dart';
import '../bloc/language_cubit.dart';
import '../bloc/tax_settings_cubit.dart';
import '../widgets/appearance_card.dart';
import '../widgets/currency_sheet.dart';
import '../widgets/language_sheet.dart';
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
    final l10n = context.l10n;
    setState(() {
      _canUndoRestore = canUndoRestore;
      if (channels case Success(:final value)) {
        final on = value.where((c) => c.isActive).length;
        final off = value.length - on;
        _channelsHint = off > 0
            ? l10n.settingsChannelsOnOff(on, off)
            : l10n.settingsChannelsOn(on);
      }
      if (orderFields case Success(:final value)) {
        final archived = value.where((f) => f.isArchived).length;
        final active = value.length - archived;
        _orderFieldsHint = value.isEmpty
            ? null
            : [
                l10n.settingsFieldsCount(active),
                if (archived > 0) l10n.settingsArchivedCount(archived),
              ].join(' · ');
      }
      if (buyList case Success(:final value)) {
        final total = value.fold<double>(0, (s, i) => s + i.totalCost);
        _buyListHint = value.isEmpty
            ? l10n.settingsNothingToBuy
            : '${l10n.settingsItemsCount(value.length)} · ${CurrencyFormatter.format(total)}';
      }
      if (notes case Success(:final value)) {
        final pinned = value.where((n) => n.isPinned).length;
        _notesHint = value.isEmpty
            ? null
            : [
                l10n.settingsNotesCount(value.length),
                if (pinned > 0) l10n.settingsPinnedCount(pinned),
              ].join(' · ');
      }
      if (receivables case Success(:final value)) {
        _receivablesHint = value.isEmpty
            ? null
            : '${CurrencyFormatter.format(value.total)} · '
                '${l10n.settingsOrdersCount(value.orderCount)}';
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
        _unitsHint = l10n.settingsUnitsSummary(value.length, startsOn);
      }
      if (social case Success(:final value)) {
        _socialHint = value.isEmpty
            ? null
            : '${l10n.settingsShortcutsCount(value.length)} · '
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

  Future<void> _pickLanguage() async {
    final cubit = getIt<LanguageCubit>();
    final picked = await showLanguageSheet(context, current: cubit.state);
    if (picked == null) return;
    await cubit.set(picked);
    // The hints under the rows are already-translated strings.
    if (mounted) _loadHints();
  }

  static String _taxHint(AppLocalizations l10n, TaxSettings tax) {
    if (!tax.enabled) return l10n.commonOff;
    final rate = tax.rate == tax.rate.roundToDouble()
        ? tax.rate.toStringAsFixed(0)
        : '${tax.rate}';
    final mode =
        tax.inclusive ? l10n.settingsTaxInPrices : l10n.settingsTaxAddedOnTop;
    final summary = l10n.settingsTaxSummary(tax.label, rate, mode);
    return tax.onByDefault
        ? summary
        : '$summary · ${l10n.settingsTaxOffByDefault}';
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
    final l10n = context.l10n;
    return BlocProvider(
      create: (_) => getIt<UpdateCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.settingsMoreTitle)),
        body: ListView(
          padding: AppSpacing.page,
          children: [
            SectionLabel(l10n.settingsSectionNotebook,
                padding: const EdgeInsets.fromLTRB(2, 2, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                MoreRow(
                  icon: Icons.sticky_note_2_outlined,
                  title: l10n.settingsNotesTitle,
                  subtitle: _notesHint ?? l10n.settingsNotesHint,
                  onTap: () => _open(RouteNames.notes),
                ),
              ]),
            ),
            SectionLabel(l10n.settingsSectionShopOnline,
                padding: const EdgeInsets.fromLTRB(2, 20, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                MoreRow(
                  icon: Icons.share_outlined,
                  title: l10n.settingsSocialTitle,
                  subtitle: _socialHint ?? l10n.settingsSocialHint,
                  onTap: () => _open(RouteNames.socialLinks),
                ),
              ]),
            ),
            SectionLabel(l10n.settingsSectionCatalogue,
                padding: const EdgeInsets.fromLTRB(2, 20, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                MoreRow(
                  icon: Icons.storefront_outlined,
                  title: l10n.settingsChannelsTitle,
                  subtitle: _channelsHint ?? l10n.settingsChannelsHint,
                  onTap: () => _open(RouteNames.channels),
                ),
                MoreRow(
                  icon: Icons.dashboard_customize_outlined,
                  title: l10n.settingsOrderFieldsTitle,
                  subtitle: _orderFieldsHint ?? l10n.settingsOrderFieldsHint,
                  onTap: () => _open(RouteNames.orderFields),
                ),
                MoreRow(
                  icon: Icons.square_foot_outlined,
                  title: l10n.settingsUnitsTitle,
                  subtitle: _unitsHint ?? l10n.settingsUnitsHint,
                  onTap: () => _open(RouteNames.units),
                ),
                MoreRow(
                  icon: Icons.shopping_basket_outlined,
                  title: l10n.settingsBuyListTitle,
                  subtitle: _buyListHint ?? l10n.settingsBuyListHint,
                  onTap: () => _open(RouteNames.buyList),
                ),
              ]),
            ),
            SectionLabel(l10n.settingsSectionMoneyOrders,
                padding: const EdgeInsets.fromLTRB(2, 20, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                MoreRow(
                  icon: Icons.schedule_rounded,
                  title: l10n.settingsReceivablesTitle,
                  subtitle: _receivablesHint ?? l10n.settingsReceivablesHint,
                  onTap: () => _open(RouteNames.receivables),
                ),
                MoreRow(
                  icon: Icons.currency_exchange_rounded,
                  title: l10n.settingsCurrencyTitle,
                  subtitle: CurrencyFormatter.currency.label,
                  onTap: _pickCurrency,
                ),
                MoreRow(
                  icon: Icons.account_balance_outlined,
                  title: l10n.settingsTaxTitle,
                  subtitle:
                      _taxHint(context.l10n, getIt<TaxSettingsCubit>().state),
                  onTap: _editTax,
                ),
                MoreRow(
                  icon: Icons.local_offer_outlined,
                  title: l10n.settingsDiscountsTitle,
                  subtitle: _discountsHint ?? l10n.settingsDiscountsHint,
                  onTap: () => _open(RouteNames.discounts),
                ),
              ]),
            ),
            SectionLabel(l10n.settingsSectionAppearance,
                padding: const EdgeInsets.fromLTRB(2, 20, 2, 0)),
            const SizedBox(height: 8),
            const AppearanceCard(),
            const SizedBox(height: 12),
            AppCard.flush(
              child: CardList(children: [
                MoreRow(
                  icon: Icons.translate_rounded,
                  title: l10n.languageTitle,
                  subtitle: getIt<LanguageCubit>().state.label(context),
                  onTap: _pickLanguage,
                ),
              ]),
            ),
            SectionLabel(l10n.settingsSectionYourData,
                padding: const EdgeInsets.fromLTRB(2, 20, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                MoreRow(
                  icon: Icons.upload_rounded,
                  title: l10n.settingsExportTitle,
                  subtitle: l10n.settingsExportHint,
                  onTap: () => BackupService.exportDatabase(context),
                ),
                MoreRow(
                  icon: Icons.download_rounded,
                  iconColor: c.alert,
                  title: l10n.settingsRestoreTitle,
                  subtitle: l10n.settingsRestoreHint,
                  onTap: () => BackupService.importDatabase(context),
                ),
                if (_canUndoRestore)
                  MoreRow(
                    icon: Icons.undo_rounded,
                    title: l10n.settingsUndoRestoreTitle,
                    subtitle: l10n.settingsUndoRestoreHint,
                    onTap: () => BackupService.undoRestore(context),
                  ),
              ]),
            ),
            SectionLabel(l10n.settingsSectionAbout,
                padding: const EdgeInsets.fromLTRB(2, 20, 2, 0)),
            const SizedBox(height: 8),
            AppCard.flush(
              child: CardList(children: [
                MoreRow(
                  icon: Icons.info_outline_rounded,
                  title: l10n.settingsAboutTitle,
                  subtitle: l10n.settingsAboutHint,
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
                      version == null
                          ? l10n.settingsFooter
                          : l10n.settingsFooterWithVersion(version),
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
