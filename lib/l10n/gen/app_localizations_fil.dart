// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Filipino Pilipino (`fil`).
class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);

  @override
  String get appName => 'CraftBook';

  @override
  String get languageTitle => 'Wika';

  @override
  String get languageSubtitle => 'Ang wikang gagamitin sa app.';

  @override
  String get languageSystem => 'Ayon sa device';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFilipino => 'Filipino (Tagalog)';

  @override
  String get commonCancel => 'Kanselahin';

  @override
  String get commonSave => 'I-save';

  @override
  String get commonDelete => 'Burahin';

  @override
  String get commonEdit => 'I-edit';

  @override
  String get commonDone => 'Tapos na';

  @override
  String get commonAdd => 'Idagdag';

  @override
  String get commonClose => 'Isara';

  @override
  String get commonTryAgain => 'Subukan ulit';

  @override
  String get commonArchive => 'I-archive';

  @override
  String get commonUnarchive => 'Alisin sa archive';

  @override
  String get commonRestore => 'Ibalik';

  @override
  String get commonUndo => 'I-undo';

  @override
  String get commonNext => 'Susunod';

  @override
  String get commonBack => 'Bumalik';

  @override
  String get commonClear => 'I-clear';

  @override
  String get commonApply => 'Ilapat';

  @override
  String get commonAll => 'Lahat';

  @override
  String get commonNone => 'Wala';

  @override
  String get commonOn => 'Naka-on';

  @override
  String get commonOff => 'Naka-off';

  @override
  String get commonName => 'Pangalan';

  @override
  String get commonNotes => 'Mga tala';

  @override
  String get commonRemove => 'Alisin';

  @override
  String get commonConfirm => 'Kumpirmahin';

  @override
  String get commonLow => 'Mababa';

  @override
  String get commonFilter => 'I-filter';

  @override
  String get commonNotSet => 'Wala pa';

  @override
  String commonClearField(String label) {
    return 'I-clear ang $label';
  }

  @override
  String get commonCouldntLoad => 'Hindi ma-load ito';

  @override
  String get navToday => 'Ngayon';

  @override
  String get navOrders => 'Orders';

  @override
  String get navInventory => 'Imbentaryo';

  @override
  String get navReports => 'Ulat';

  @override
  String get navMore => 'Iba pa';

  @override
  String get dateToday => 'Ngayon';

  @override
  String get dateTomorrow => 'Bukas';

  @override
  String get dateYesterday => 'Kahapon';

  @override
  String dateInDays(int count) {
    return 'Sa loob ng $count araw';
  }

  @override
  String dateDaysAgo(int count) {
    return '$count araw na ang nakalipas';
  }

  @override
  String get moneySales => 'Benta';

  @override
  String get moneyDiscounts => 'Mga diskwento';

  @override
  String get moneyTax => 'Tax';

  @override
  String moneyTaxInPrices(String tax) {
    return '$tax na kasama sa presyo';
  }

  @override
  String get moneyMaterials => 'Mga materyales';

  @override
  String get moneyChannelFees => 'Fees ng channel';

  @override
  String get moneyShipping => 'Shipping';

  @override
  String moneyAddedTaxNote(String amount, String tax) {
    return '+ $amount $tax na dinagdag para bayaran ng customer. Hindi ito sa iyo, kaya wala ito sa profit.';
  }

  @override
  String moneyProfitMargin(int margin) {
    return 'Profit · $margin% margin';
  }

  @override
  String moneyProfitSemantics(String profit, String sales) {
    return 'Profit na $profit mula sa benta na $sales';
  }

  @override
  String get pipFree => 'libre';

  @override
  String get pipPromised => 'nakareserba';

  @override
  String get pipReorderLevel => 'antas ng re-order';

  @override
  String productPhotoOf(String name) {
    return 'Larawan ng $name';
  }

  @override
  String get appLogoLabel => 'Logo ng CraftBook';

  @override
  String get noteToolRedo => 'I-redo';

  @override
  String get noteToolBold => 'Bold';

  @override
  String get noteToolItalic => 'Italic';

  @override
  String get noteToolUnderline => 'Underline';

  @override
  String get noteToolStrikethrough => 'Strikethrough';

  @override
  String get noteToolInlineCode => 'Inline code';

  @override
  String get noteToolHighlight => 'I-highlight';

  @override
  String get noteToolLargeHeading => 'Malaking heading';

  @override
  String get noteToolHeading => 'Heading';

  @override
  String get noteToolSmallHeading => 'Maliit na heading';

  @override
  String get noteToolChecklist => 'Checklist';

  @override
  String get noteToolBulletList => 'Bullet list';

  @override
  String get noteToolNumberedList => 'Numbered list';

  @override
  String get noteToolQuote => 'Quote';

  @override
  String get noteToolCodeBlock => 'Code block';

  @override
  String get noteToolOutdent => 'Ilabas ang indent';

  @override
  String get noteToolIndent => 'Indent';

  @override
  String get noteToolAlignCentre => 'Igitna';

  @override
  String get noteToolAlignRight => 'Ikanan';

  @override
  String get noteToolLink => 'Link';

  @override
  String get noteToolClearFormatting => 'Alisin ang format';

  @override
  String get noteLinkAdd => 'Magdagdag ng link';

  @override
  String get noteLinkEdit => 'I-edit ang link';

  @override
  String get noteLinkAddress => 'Address';

  @override
  String get noteLinkRemove => 'Alisin ang link';

  @override
  String get noteHighlightSand => 'Buhangin';

  @override
  String get noteHighlightGreen => 'Berde';

  @override
  String get noteHighlightLavender => 'Lavender';

  @override
  String get noteHighlightRose => 'Rosas';

  @override
  String get backupProblemNotSqlite => 'Hindi ito backup file ng Craftbook.';

  @override
  String get backupProblemCorrupt =>
      'Sira ang backup na ito at hindi na maibabalik.';

  @override
  String get backupProblemWrongApp =>
      'Sa ibang app ang file na ito, hindi sa Craftbook.';

  @override
  String get backupProblemNewerVersion =>
      'Mas bagong Craftbook ang gumawa ng backup na ito. I-update muna ang app.';

  @override
  String get backupProblemUpgradeFailed =>
      'Hindi ma-upgrade ang backup na ito para sa bersyong ito ng Craftbook.';

  @override
  String get backupProblemSchemaMismatch =>
      'May kulang na data sa backup na ito na kailangan ng Craftbook.';

  @override
  String get backupSaveDialogTitle => 'I-save ang backup';

  @override
  String get backupSaved => 'Matagumpay na na-save ang backup';

  @override
  String backupExportFailed(String error) {
    return 'Hindi na-export: $error';
  }

  @override
  String get backupPickDialogTitle => 'Pumili ng backup file';

  @override
  String get backupRestoreTitle => 'Ibalik ang backup na ito?';

  @override
  String backupRestoreMessage(String summary) {
    return '$summary\n\nPapalitan nito ang lahat ng nasa phone na ito. Maaari mo itong i-undo sa Iba pa.';
  }

  @override
  String backupContents(int orders, int materials, int products) {
    return '$orders order, $materials materyal at $products produkto.';
  }

  @override
  String backupContentsUpgraded(String contents) {
    return '$contents Mas lumang Craftbook ang gumawa nito at na-upgrade na.';
  }

  @override
  String get backupRestored => 'Naibalik ang backup';

  @override
  String backupRestoreFailed(String error) {
    return 'Hindi naibalik: $error';
  }

  @override
  String get backupUndoTitle => 'I-undo ang huling pagbabalik?';

  @override
  String get backupUndoMessage =>
      'Babalik sa data mo bago ang huling restore. Mawawala ang anumang binago mula noon.';

  @override
  String get backupUndoConfirm => 'I-undo ang restore';

  @override
  String backupCantUndo(String reason) {
    return 'Hindi ma-undo: $reason';
  }

  @override
  String get backupRestoreUndone => 'Na-undo ang restore';

  @override
  String backupUndoFailed(String error) {
    return 'Hindi na-undo: $error';
  }

  @override
  String backupSwapFailed(String error) {
    return 'Hindi naibalik, walang nabago: $error';
  }

  @override
  String backupRestartApp(String message) {
    return '$message. I-restart ang app.';
  }

  @override
  String get settingsMoreTitle => 'Iba pa';

  @override
  String get settingsSectionNotebook => 'Notebook';

  @override
  String get settingsSectionShopOnline => 'Ang shop mo online';

  @override
  String get settingsSectionCatalogue => 'Katalogo';

  @override
  String get settingsSectionMoneyOrders => 'Pera at orders';

  @override
  String get settingsSectionAppearance => 'Itsura';

  @override
  String get settingsSectionYourData => 'Ang data mo';

  @override
  String get settingsSectionAbout => 'Tungkol';

  @override
  String get settingsNotesTitle => 'Mga tala';

  @override
  String get settingsNotesHint => 'Detalye ng supplier, ideya, paano-gawin';

  @override
  String get settingsSocialTitle => 'Mga social shortcut';

  @override
  String get settingsSocialHint => 'Facebook, TikTok, Shopee, Lazada…';

  @override
  String get settingsChannelsTitle => 'Mga channel at fees';

  @override
  String get settingsChannelsHint =>
      'Kung saan ka nagbebenta at magkano ang singil nila';

  @override
  String get settingsOrderFieldsTitle => 'Mga field ng order';

  @override
  String get settingsOrderFieldsHint =>
      'Dagdag na detalyeng itatala sa bawat order';

  @override
  String get settingsUnitsTitle => 'Mga yunit ng sukat';

  @override
  String get settingsUnitsHint => 'Kung paano mo binibilang ang mga bagay';

  @override
  String get settingsBuyListTitle => 'Listahan ng bibilhin';

  @override
  String get settingsBuyListHint => 'Mga kailangang i-restock';

  @override
  String get settingsReceivablesTitle => 'Naghihintay ng bayad';

  @override
  String get settingsReceivablesHint => 'Bayad na ang lahat';

  @override
  String get settingsCurrencyTitle => 'Currency';

  @override
  String get settingsTaxTitle => 'Tax';

  @override
  String get settingsDiscountsTitle => 'Mga diskwento';

  @override
  String get settingsDiscountsHint => 'Mga madalas mong ibigay';

  @override
  String get settingsExportTitle => 'I-export ang backup';

  @override
  String get settingsExportHint => 'Mag-save ng kopya ng lahat sa isang file';

  @override
  String get settingsRestoreTitle => 'Ibalik mula sa backup';

  @override
  String get settingsRestoreHint => 'Papalitan nito ang lahat sa phone na ito';

  @override
  String get settingsUndoRestoreTitle => 'I-undo ang huling restore';

  @override
  String get settingsUndoRestoreHint => 'Bumalik sa data bago nito';

  @override
  String get settingsAboutTitle => 'Tungkol sa Craftbook';

  @override
  String get settingsAboutHint => 'Ano ang ginagawa nito at paano gamitin';

  @override
  String settingsFooterWithVersion(String version) {
    return 'Bersyon $version · nananatili sa phone na ito ang lahat ng data';
  }

  @override
  String get settingsFooter => 'Nananatili sa phone na ito ang lahat ng data';

  @override
  String settingsChannelsOn(int on) {
    return '$on naka-on';
  }

  @override
  String settingsChannelsOnOff(int on, int off) {
    return '$on naka-on · $off naka-off';
  }

  @override
  String settingsFieldsCount(int count) {
    return '$count field';
  }

  @override
  String settingsArchivedCount(int count) {
    return '$count naka-archive';
  }

  @override
  String get settingsNothingToBuy => 'Walang bibilhin';

  @override
  String settingsItemsCount(int count) {
    return '$count item';
  }

  @override
  String settingsNotesCount(int count) {
    return '$count tala';
  }

  @override
  String settingsPinnedCount(int count) {
    return '$count naka-pin';
  }

  @override
  String settingsOrdersCount(int count) {
    return '$count order';
  }

  @override
  String settingsShortcutsCount(int count) {
    return '$count shortcut';
  }

  @override
  String settingsUnitsSummary(int count, String unit) {
    return '$count · magsisimula ang mga bagong item sa $unit';
  }

  @override
  String settingsTaxSummary(String label, String rate, String mode) {
    return '$label $rate% · $mode';
  }

  @override
  String get settingsTaxInPrices => 'kasama sa presyo';

  @override
  String get settingsTaxAddedOnTop => 'dinagdag sa ibabaw';

  @override
  String get settingsTaxOffByDefault => 'naka-off bilang default';

  @override
  String get aboutTitle => 'Tungkol';

  @override
  String get aboutLoadFailed => 'Hindi ma-load ang gabay. Pakisubukan ulit.';

  @override
  String get appearanceColourScheme => 'Kulay ng app';

  @override
  String appearanceColourSchemeLabel(String name) {
    return 'Kulay na $name';
  }

  @override
  String get appearancePaletteForest => 'Gubat';

  @override
  String get appearancePaletteBerry => 'Berry';

  @override
  String get appearancePaletteOcean => 'Karagatan';

  @override
  String get appearancePaletteSunset => 'Paglubog ng araw';

  @override
  String get appearanceDarkMode => 'Dark mode';

  @override
  String get appearanceDarkAutoHint => 'Sinusunod ng Auto ang phone mo';

  @override
  String get appearanceDarkOverrideHint =>
      'Mas mananaig ito kaysa sa setting ng phone mo';

  @override
  String get appearanceAuto => 'Auto';

  @override
  String get appearanceOrderCardsShow => 'Ipinapakita ng order card';

  @override
  String get appearanceShowsTotalHint => 'Ang binabayaran ng customer';

  @override
  String get appearanceShowsProfitHint =>
      'Ang matitira sa iyo pagkatapos ng gastos';

  @override
  String get appearanceTotal => 'Kabuuan';

  @override
  String get appearanceProfit => 'Profit';

  @override
  String get taxSheetTitle => 'Tax';

  @override
  String get taxSheetSubtitle =>
      'Kinukuwenta ang tax sa bawat order para alam mo kung magkano ang itatabi.';

  @override
  String taxExampleIncluded(String price, String tax, String name) {
    return 'Ang benta na $price ay may kasamang $tax na $name. Mababawas ito sa profit mo.';
  }

  @override
  String taxExampleOnTop(String price, String total, String tax, String name) {
    return 'Ang benta na $price ay babayaran ng customer ng $total. Ang $tax na $name ay sila ang magbabayad, kaya hindi ito binibilang na profit.';
  }

  @override
  String get taxUse => 'Gumamit ng tax';

  @override
  String get taxUseOnHint => 'May tax switch ang bawat order';

  @override
  String get taxUseOffHint =>
      'Walang tax ang mga order. Mananatili ang tax ng mga na-save na order';

  @override
  String get taxNewOrders => 'May tax agad ang mga bagong order';

  @override
  String get taxNewOrdersOnHint =>
      'I-off sa mga order na hindi nangangailangan nito';

  @override
  String get taxNewOrdersOffHint =>
      'I-on kapag kailangan ng customer, tulad ng para sa official receipt';

  @override
  String get taxCalled => 'Tawag';

  @override
  String get taxRate => 'Rate';

  @override
  String get taxYourPrices => 'Ang mga presyo mo';

  @override
  String get taxIncluded => 'May kasamang tax na';

  @override
  String get taxOnTop => 'Dinadagdag ang tax';

  @override
  String get currencySheetTitle => 'Currency';

  @override
  String get currencySheetSubtitle =>
      'Simbolo lang ang magbabago. Hindi kino-convert ang mga halaga.';

  @override
  String get currencySomethingElse => 'Iba pa';

  @override
  String get currencySymbol => 'Simbolo';

  @override
  String get currencySymbolHint => 'hal. kr';

  @override
  String get currencyUse => 'Gamitin';

  @override
  String get currencyNoCents => 'Walang sentimo';

  @override
  String get currencyNoCentsHint => 'Ipakita ang 1,200 sa halip na 1,200.00';

  @override
  String pipSummary(String free, String promised) {
    return '$free libre, $promised naka-reserba';
  }

  @override
  String pipSummaryReorder(String free, String promised, String level) {
    return '$free libre, $promised naka-reserba, mag-reorder sa $level';
  }

  @override
  String get earningsTitle => 'Mga Ulat';

  @override
  String get earningsRangeWeek => 'Linggo';

  @override
  String get earningsRangeMonth => 'Buwan';

  @override
  String get earningsRangeYear => 'Taon';

  @override
  String get earningsRangeCustom => 'Piliin';

  @override
  String get earningsPickerHelp => 'Ulat para sa';

  @override
  String get earningsPickerShow => 'Ipakita';

  @override
  String get earningsPrevious => 'Nakaraan';

  @override
  String earningsOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count order',
    );
    return '$_temp0';
  }

  @override
  String earningsCustomers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count customer',
    );
    return '$_temp0';
  }

  @override
  String earningsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count araw',
    );
    return '$_temp0';
  }

  @override
  String earningsNetProfit(String orders) {
    return 'Netong tubo · $orders';
  }

  @override
  String get earningsNoOrders =>
      'Walang naka-pack o naipadalang order sa panahong ito. Mabibilang ang tubo kapag na-pack na ang order.';

  @override
  String get earningsNoOrdersFiltered =>
      'Walang naka-pack o naipadalang order sa panahong ito na tumutugma sa filter.';

  @override
  String earningsMargin(String percent) {
    return '$percent% ng benta ay tubo';
  }

  @override
  String earningsUnpaidLine(String amount, String orders) {
    return '$amount nito ay hindi pa bayad ($orders)';
  }

  @override
  String earningsByProduct(int count) {
    return 'Ayon sa produkto · $count';
  }

  @override
  String earningsSoldSales(String sold, String sales) {
    return '$sold naibenta · $sales benta';
  }

  @override
  String get earningsWaste => 'Sayang';

  @override
  String earningsWasteWithCost(String cost) {
    return 'Sayang · $cost';
  }

  @override
  String get earningsNoWaste => 'Walang naitalang sayang sa panahong ito.';

  @override
  String earningsWasted(String quantity) {
    return '$quantity nasayang';
  }

  @override
  String get earningsWaiting => 'Naghihintay ng bayad';

  @override
  String earningsWaitingSubtitle(String orders, String customers) {
    return '$orders · $customers';
  }

  @override
  String get earningsThisWeek => 'Ngayong linggo';

  @override
  String get earningsThisMonth => 'Ngayong buwan';

  @override
  String get earningsThisYear => 'Ngayong taon';

  @override
  String get earningsLastWeek => 'Nakaraang linggo';

  @override
  String get earningsLastMonth => 'Nakaraang buwan';

  @override
  String get earningsProduct => 'Produkto';

  @override
  String get earningsProductEarnings => 'Kita ng produkto';

  @override
  String get earningsProfitCaption => 'TUBO';

  @override
  String get earningsStatSold => 'Naibenta';

  @override
  String get earningsStatSales => 'Benta';

  @override
  String get earningsStatPerItem => 'Bawat isa';

  @override
  String earningsStatPerUnit(String unit) {
    return 'Bawat $unit';
  }

  @override
  String earningsOrdersHeader(int count) {
    return 'Mga order · $count';
  }

  @override
  String get earningsNoProductOrders =>
      'Walang naka-pack o naipadalang order na may produktong ito sa panahong ito.';

  @override
  String get earningsProfitSplitNote =>
      'Hinahati ang tubo ng bawat order sa mga produkto nito ayon sa bahagi ng benta.';

  @override
  String get earningsFilterTitle => 'I-filter ang ulat';

  @override
  String get earningsFilterSubtitle =>
      'Mabibilang lang ang mga order na tumutugma sa lahat ng pinili.';

  @override
  String get earningsFilterChannel => 'Channel';

  @override
  String get earningsFilterProducts => 'May alinman sa mga produktong ito';

  @override
  String get earningsFilterStatus => 'Katayuan';

  @override
  String get earningsFilterPayment => 'Bayad';

  @override
  String get earningsFilterDiscount => 'Diskwento';

  @override
  String get earningsFilterTax => 'Tax';

  @override
  String get earningsFilterTotal => 'Kabuuan ng order';

  @override
  String get earningsFilterFrom => 'Mula';

  @override
  String get earningsFilterTo => 'Hanggang';

  @override
  String get earningsFilterClear => 'Alisin lahat';

  @override
  String get earningsFilterShow => 'Ipakita';

  @override
  String get earningsAny => 'Lahat';

  @override
  String get earningsPacked => 'Naka-pack';

  @override
  String get earningsShipped => 'Naipadala';

  @override
  String get earningsPaid => 'Bayad na';

  @override
  String get earningsUnpaid => 'Hindi pa bayad';

  @override
  String get earningsWithDiscount => 'May diskwento';

  @override
  String get earningsNoDiscount => 'Walang diskwento';

  @override
  String get earningsWithTax => 'May tax';

  @override
  String get earningsNoTax => 'Walang tax';

  @override
  String get earningsChipChannel => 'channel';

  @override
  String earningsChipChannels(int count) {
    return '$count channel';
  }

  @override
  String get earningsChipProduct => 'produkto';

  @override
  String earningsChipProducts(int count) {
    return '$count produkto';
  }

  @override
  String get earningsChipPackedOnly => 'Naka-pack lang';

  @override
  String get earningsChipShippedOnly => 'Naipadala lang';

  @override
  String get earningsChipPackedOrShipped => 'Naka-pack o naipadala';

  @override
  String earningsChipRange(String min, String max) {
    return '$min–$max';
  }

  @override
  String earningsChipAndUp(String min) {
    return '$min pataas';
  }

  @override
  String earningsChipUpTo(String max) {
    return 'Hanggang $max';
  }

  @override
  String get notesEmptyTitle => 'Wala pang tala';

  @override
  String get notesEmptyMessage =>
      'Dito itago ang detalye ng supplier, ideya sa produkto, at paraan ng pagpa-pack.';

  @override
  String get notesAddNote => 'Magdagdag ng tala';

  @override
  String get notesFab => 'Tala';

  @override
  String get notesSearchHint => 'Maghanap ng tala';

  @override
  String get notesNoMatches => 'Walang nahanap';

  @override
  String notesNoMatchesMessage(String query) {
    return 'Walang talang may \"$query\".';
  }

  @override
  String notesPinnedHeader(int count) {
    return 'Naka-pin · $count';
  }

  @override
  String notesOthersHeader(int count) {
    return 'Iba pa · $count';
  }

  @override
  String get notesUntitled => 'Walang pamagat';

  @override
  String get notesPinToToday => 'I-pin sa Today';

  @override
  String get notesUnpin => 'I-unpin';

  @override
  String get notesPin => 'I-pin';

  @override
  String get notesPinnedLabel => 'Naka-pin';

  @override
  String get notesDeleteTitle => 'I-delete ang tala?';

  @override
  String notesDeleteMessage(String title) {
    return 'Aalisin ang $title sa notebook mo.';
  }

  @override
  String notesChecklistDone(int done, int total) {
    return '$done/$total tapos na';
  }

  @override
  String get notesOutcomePinned => 'Naka-pin na sa Today';

  @override
  String get notesOutcomeUnpinned => 'Na-unpin na';

  @override
  String notesOutcomeDeleted(String title) {
    return 'Na-delete ang $title';
  }

  @override
  String notesOutcomeRestored(String title) {
    return 'Naibalik ang $title';
  }

  @override
  String get notesDiscardTitle => 'I-discard ang mga pagbabago?';

  @override
  String get notesDiscardNew => 'Hindi pa na-save ang tala.';

  @override
  String get notesDiscardEdit => 'Mananatili ang tala kung paano ito dati.';

  @override
  String get notesDiscardConfirm => 'I-discard';

  @override
  String get notesKeepEditing => 'Ituloy ang pag-edit';

  @override
  String get notesNewNote => 'Bagong tala';

  @override
  String get notesEditNote => 'I-edit ang tala';

  @override
  String get notesMore => 'Higit pa';

  @override
  String get notesTitleHint => 'Pamagat';

  @override
  String get notesBodyHint => 'Detalye ng supplier, ideya, paraan ng paggawa…';

  @override
  String get orderFieldsTitle => 'Mga field ng order';

  @override
  String get orderFieldsEmptyTitle => 'Wala pang field ng order';

  @override
  String get orderFieldsEmptyMessage =>
      'Idagdag ang isinusulat mo sa bawat order: address, laki, mensahe sa regalo…';

  @override
  String get orderFieldsAddField => 'Magdagdag ng field';

  @override
  String get orderFieldsFab => 'Field';

  @override
  String get orderFieldsDragReorder => 'I-drag para ayusin ang pagkakasunod';

  @override
  String get orderFieldsArchivedHeader => 'Naka-archive';

  @override
  String orderFieldsDeleteNamed(String name) {
    return 'I-delete ang $name';
  }

  @override
  String get orderFieldsFooter =>
      'Ganito ang pagkakasunod ng pagtatanong ng mga field kapag nagdagdag ka ng order. Nananatili sa mga lumang order ang mga naka-archive na field pero hindi na ito itatanong sa mga bago.';

  @override
  String get orderFieldsEditField => 'I-edit ang field';

  @override
  String orderFieldsArchiveTitle(String name) {
    return 'I-archive ang $name?';
  }

  @override
  String orderFieldsDeleteTitle(String name) {
    return 'I-delete ang $name?';
  }

  @override
  String orderFieldsArchiveMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count order',
    );
    return 'Mananatili ito sa $_temp0 na gumagamit nito, pero hindi na ito itatanong sa mga bagong order.';
  }

  @override
  String get orderFieldsDeleteMessage =>
      'Walang order na gumagamit nito, kaya tuluyan itong aalisin.';

  @override
  String get orderFieldsNewField => 'Bagong field ng order';

  @override
  String orderFieldsEditNamed(String name) {
    return 'I-edit ang $name';
  }

  @override
  String get orderFieldsNameHint => 'hal. Address';

  @override
  String get orderFieldsNameRequired => 'Maglagay ng pangalan';

  @override
  String get orderFieldsTypeLabel => 'Uri';

  @override
  String get orderFieldsTypeText => 'Teksto';

  @override
  String get orderFieldsTypeNumber => 'Numero';

  @override
  String get orderFieldsTypeDate => 'Petsa';

  @override
  String get orderFieldsTypeChoice => 'Pagpipilian';

  @override
  String get orderFieldsTypeLocked =>
      'Hindi na mapapalitan ang uri kapag may order nang gumagamit nito.';

  @override
  String get orderFieldsNumberNote =>
      'Natatanggal ang mga zero sa unahan ng numero. Gamitin ang Teksto para sa mga numero ng telepono.';

  @override
  String get orderFieldsMultiline => 'Maraming linya';

  @override
  String get orderFieldsMultilineHint =>
      'Para sa mas mahabang teksto tulad ng address';

  @override
  String get orderFieldsChoices => 'Mga pagpipilian';

  @override
  String orderFieldsChoiceHint(int number) {
    return 'Pagpipilian $number';
  }

  @override
  String get orderFieldsChoiceRequired =>
      'Magdagdag ng kahit isang pagpipilian';

  @override
  String get orderFieldsRemoveChoice => 'Alisin ang pagpipilian';

  @override
  String get orderFieldsAddChoice => 'Magdagdag ng pagpipilian';

  @override
  String get orderFieldsChoicesKept =>
      'Nananatili sa mga order ang pagpipiliang na-save sa kanila, kahit palitan mo ng pangalan o alisin ito dito.';

  @override
  String get orderFieldsEnterNumber => 'Maglagay ng numero';

  @override
  String orderFieldsChoiceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagpipilian',
    );
    return '$_temp0';
  }

  @override
  String orderFieldsUsedOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count order',
    );
    return 'ginamit sa $_temp0';
  }

  @override
  String get orderFieldsNotUsed => 'hindi pa nagagamit';

  @override
  String get orderFieldsFallbackName => 'Field';

  @override
  String orderFieldsOutcomeAdded(String name) {
    return 'Naidagdag ang $name';
  }

  @override
  String orderFieldsOutcomeSaved(String name) {
    return 'Na-save ang $name';
  }

  @override
  String orderFieldsOutcomeArchived(String name) {
    return 'Na-archive ang $name';
  }

  @override
  String orderFieldsOutcomeDeleted(String name) {
    return 'Na-delete ang $name';
  }

  @override
  String orderFieldsOutcomeRestored(String name) {
    return 'Naibalik ang $name';
  }

  @override
  String get socialTitle => 'Mga shortcut sa social';

  @override
  String get socialEmptyTitle => 'Wala pang shortcut';

  @override
  String get socialEmptyMessage =>
      'Gawing isang tap na lang ang Facebook, TikTok, Shopee o Lazada page mo.';

  @override
  String get socialAddShortcut => 'Magdagdag ng shortcut';

  @override
  String get socialFab => 'Shortcut';

  @override
  String get socialOpen => 'Buksan';

  @override
  String get socialEditShortcut => 'I-edit ang shortcut';

  @override
  String socialRemoveTitle(String name) {
    return 'Alisin ang $name?';
  }

  @override
  String get socialRemoveMessage =>
      'Shortcut lang ang mawawala; walang mababago sa mismong page.';

  @override
  String get socialHint =>
      'I-tap ang shortcut para buksan ito sa browser o sa app. I-tap ang I-edit para ayusin o baguhin ang mga ito.';

  @override
  String get socialNewShortcut => 'Bagong shortcut';

  @override
  String socialEditNamed(String name) {
    return 'I-edit ang $name';
  }

  @override
  String get socialSite => 'Site';

  @override
  String get socialOther => 'Iba pa';

  @override
  String get socialNameHint => 'hal. Aking website';

  @override
  String get socialNameRequired => 'Maglagay ng pangalan';

  @override
  String get socialLinkLabel => 'Link';

  @override
  String socialLinkInvalid(String example) {
    return 'Maglagay ng web address tulad ng $example';
  }

  @override
  String get socialColour => 'Kulay';

  @override
  String socialCouldntOpen(String name) {
    return 'Hindi mabuksan ang $name. Tingnan ang link.';
  }

  @override
  String socialOpenNamed(String name) {
    return 'Buksan ang $name';
  }

  @override
  String get socialDragReorder => 'I-drag para ayusin ang pagkakasunod';

  @override
  String get socialFallbackName => 'Shortcut';

  @override
  String socialOutcomeAdded(String name) {
    return 'Naidagdag ang $name';
  }

  @override
  String socialOutcomeSaved(String name) {
    return 'Na-save ang $name';
  }

  @override
  String socialOutcomeRemoved(String name) {
    return 'Naalis ang $name';
  }

  @override
  String get updatesCheck => 'Tingnan kung may update';

  @override
  String get updatesCheckSubtitle =>
      'Kunin ang pinakabagong bersyon ng Craftbook';

  @override
  String get updatesChecking => 'Tinitingnan…';

  @override
  String get updatesUpToDate => 'Pinakabago na ang bersyon mo';

  @override
  String updatesUpdateTo(String version) {
    return 'I-update sa $version';
  }

  @override
  String get updatesTapToInstall => 'I-tap para i-download at i-install';

  @override
  String get updatesDownloading => 'Dina-download…';

  @override
  String updatesDownloadingPercent(int percent) {
    return 'Dina-download… $percent%';
  }

  @override
  String get updatesFailedFallback =>
      'May nangyaring mali. I-tap para subukan ulit.';

  @override
  String get updatesDialogMessage =>
      'Mananatili ang mga order, stock, at tala mo.';

  @override
  String get updatesConfirm => 'I-update';

  @override
  String get updatesLater => 'Mamaya na';

  @override
  String get ordersStatusToPack => 'Para i-pack';

  @override
  String get ordersStatusPacked => 'Naka-pack na';

  @override
  String get ordersStatusShipped => 'Naipadala na';

  @override
  String get ordersStatusCancelled => 'Kinansela';

  @override
  String get ordersOverdue => 'Lagpas na';

  @override
  String get ordersPaymentAny => 'Lahat';

  @override
  String get ordersPaymentUnpaid => 'Hindi pa bayad';

  @override
  String get ordersPaymentPaid => 'Bayad na';

  @override
  String get ordersFilterTitle => 'I-filter ang mga order';

  @override
  String get ordersFilterSubtitle =>
      'Gumagana kasabay ng mga status chip at paghahanap.';

  @override
  String get ordersFilterPayment => 'Bayad';

  @override
  String get ordersFilterClearAll => 'I-clear lahat';

  @override
  String get ordersFilterShow => 'Ipakita';

  @override
  String ordersItemCount(num count, String qty) {
    return '$qty item';
  }

  @override
  String ordersOrderCount(int count) {
    return '$count order';
  }

  @override
  String ordersLineCount(int count) {
    return '$count linya';
  }

  @override
  String ordersMiniProfit(String amount) {
    return '$amount tubo';
  }

  @override
  String get ordersUnpaidTag => 'Hindi pa bayad';

  @override
  String get ordersDateToday => 'Ngayon';

  @override
  String get ordersDateTomorrow => 'Bukas';

  @override
  String get ordersDateYesterday => 'Kahapon';

  @override
  String get ordersWhenShipped => 'Naipadala';

  @override
  String ordersWhenShippedOn(String date) {
    return 'Naipadala $date';
  }

  @override
  String get ordersWhenCancelled => 'Kinansela';

  @override
  String get ordersWhenDueYesterday => 'Due kahapon';

  @override
  String ordersWhenDueDaysAgo(int count) {
    return 'Due $count araw na ang nakalipas';
  }

  @override
  String get ordersWhenShipsToday => 'Ipapadala ngayon';

  @override
  String ordersWhenShips(String date) {
    return 'Ipapadala $date';
  }

  @override
  String ordersActionTitle(String id, String customer) {
    return 'Order #$id · $customer';
  }

  @override
  String get ordersMarkShipped => 'Markahan bilang naipadala';

  @override
  String get ordersMarkPaid => 'Markahan bilang bayad na';

  @override
  String get ordersMarkUnpaid => 'Markahan bilang hindi pa bayad';

  @override
  String get ordersEditNote => 'I-edit ang note';

  @override
  String get ordersEditOrder => 'I-edit ang order';

  @override
  String get ordersCancelOrder => 'Kanselahin ang order';

  @override
  String get ordersRestoreOrder => 'Ibalik ang order';

  @override
  String get ordersDeleteOrder => 'Burahin ang order';

  @override
  String get ordersToastShipped => 'Namarkahan bilang naipadala';

  @override
  String get ordersToastPaid => 'Namarkahan bilang bayad na';

  @override
  String get ordersToastUnpaid => 'Namarkahan bilang hindi pa bayad';

  @override
  String get ordersToastCancelled => 'Nakansela ang order. Naibalik ang stock.';

  @override
  String get ordersToastRestored => 'Naibalik ang order';

  @override
  String get ordersToastDeleted => 'Nabura ang order';

  @override
  String get ordersToastPacked => 'Na-pack na. Na-update ang stock.';

  @override
  String get ordersToastMaterialsUpdated => 'Na-update ang mga materyales';

  @override
  String ordersCancelTitle(String id) {
    return 'Kanselahin ang order #$id?';
  }

  @override
  String get ordersCancelMessageShipped =>
      'Gamitin ito kung ibinalik ito o hindi natuloy ang padala. Babalik sa shelf ang mga materyales nito, at mananatili ang order sa listahan bilang kinansela, hindi kasama sa mga report. Puwede mo itong burahin pagkatapos.';

  @override
  String get ordersCancelMessagePacked =>
      'Babalik sa shelf ang mga materyales nito. Mananatili ang order sa listahan bilang kinansela at hindi ito kasama sa kita.';

  @override
  String get ordersCancelMessagePending =>
      'Ilalabas ang naka-reserve nitong stock. Mananatili ang order sa listahan bilang kinansela at hindi ito kasama sa kita.';

  @override
  String get ordersCancelConfirm => 'Kanselahin ang order';

  @override
  String get ordersCancelKeep => 'Huwag kanselahin';

  @override
  String ordersRestoreTitle(String id) {
    return 'Ibalik ang order #$id?';
  }

  @override
  String get ordersRestoreMessage =>
      'Babalik ito sa Para i-pack at ire-reserve ulit ang mga materyales nito.';

  @override
  String ordersDeleteTitle(String id) {
    return 'Burahin ang order #$id?';
  }

  @override
  String get ordersDeleteMessagePacked =>
      'Mabubura ang order at babalik sa shelf ang mga materyales nito.';

  @override
  String get ordersDeleteMessageCancelled =>
      'Tuluyang mabubura ang kinanselang order.';

  @override
  String get ordersDeleteMessagePending =>
      'Mabubura ang order at ilalabas ang naka-reserve nitong stock.';

  @override
  String get ordersNoteOptional => 'Note (opsyonal)';

  @override
  String get ordersNotePlaceholder =>
      'Gift wrap, hiling na kulay, mga hakbang sa pag-pack…';

  @override
  String get ordersNoteAdd => 'Magdagdag ng note';

  @override
  String get ordersDiscardChangesTitle => 'Itatapon ang mga pagbabago?';

  @override
  String get ordersNoteStaysMessage =>
      'Mananatili ang note kung paano ito dati.';

  @override
  String get ordersDiscard => 'Itapon';

  @override
  String get ordersKeepEditing => 'Ituloy ang pag-edit';

  @override
  String get ordersTitle => 'Mga order';

  @override
  String get ordersNewOrder => 'Bagong order';

  @override
  String get ordersSearchHint => 'Maghanap ng pangalan, # o channel';

  @override
  String get ordersGroupPacked => 'Naka-pack, handa nang ipadala';

  @override
  String get ordersGroupDueThisWeek => 'Due ngayong linggo';

  @override
  String get ordersGroupLater => 'Mamaya pa';

  @override
  String get ordersEmptyNoneTitle => 'Wala pang order';

  @override
  String get ordersEmptyNoneMessage => 'Dito lalabas ang una mong order.';

  @override
  String get ordersNoMatches => 'Walang tugma';

  @override
  String ordersNoMatchesFor(String query) {
    return 'Walang tugma sa “$query”.';
  }

  @override
  String get ordersNothingWaiting => 'Walang naghihintay ng bayad';

  @override
  String get ordersNoPaidHere => 'Walang bayad na order dito';

  @override
  String get ordersNothingToPack => 'Walang i-pa-pack';

  @override
  String get ordersAllPackedMessage =>
      'Naka-pack na lahat ng order. Ang galing!';

  @override
  String ordersNoStatusOrders(String status) {
    return 'Walang order na $status';
  }

  @override
  String get ordersReceivablesTitle => 'Naghihintay ng bayad';

  @override
  String get ordersReceivablesEmptyTitle => 'Bayad na ang lahat';

  @override
  String get ordersReceivablesEmptyMessage =>
      'Dito lalabas ang mga order na minarkahang hindi pa bayad.';

  @override
  String ordersReceivablesOwed(String orders) {
    return 'Utang sa iyo · $orders';
  }

  @override
  String get ordersReceivablesHint =>
      'I-mark na bayad ang order sa pahina nito o sa pamamagitan ng matagal na pagpindot.';

  @override
  String ordersDetailHeader(String id) {
    return 'ORDER #$id';
  }

  @override
  String get ordersMenuMore => 'Higit pa';

  @override
  String get ordersItemsCaps => 'MGA ITEM';

  @override
  String get ordersPlaced => 'Inilagay';

  @override
  String ordersPlacedOn(String date) {
    return 'Inilagay noong $date';
  }

  @override
  String ordersDueOn(String date) {
    return 'due $date';
  }

  @override
  String get ordersCustomer => 'Customer';

  @override
  String ordersFieldCopied(String label) {
    return 'Nakopya ang $label';
  }

  @override
  String get ordersDiscountsLine => 'Mga discount';

  @override
  String get ordersItemsLine => 'Mga item';

  @override
  String ordersIncludesTax(String amount, String tax, String rate) {
    return 'Kasama ang $amount na $tax ($rate%)';
  }

  @override
  String ordersPaidOn(String date) {
    return 'Bayad noong $date';
  }

  @override
  String get ordersPaid => 'Bayad na';

  @override
  String get ordersWaitingForPayment => 'Naghihintay ng bayad';

  @override
  String get ordersTotalCaps => 'KABUUANG ORDER';

  @override
  String get ordersAdjust => 'I-adjust';

  @override
  String get ordersPackOrder => 'I-pack ang order';

  @override
  String get ordersMaterials => 'Mga materyales';

  @override
  String ordersMaterialsLines(String lines) {
    return 'Mga materyales · $lines';
  }

  @override
  String ordersMaterialsLinesWaste(String lines) {
    return 'Mga materyales · $lines · waste';
  }

  @override
  String get ordersChannelFees => 'Fee ng channel';

  @override
  String ordersChannelFeesNamed(String channel) {
    return 'Fee ng $channel';
  }

  @override
  String ordersPlannedUsed(String planned, String used) {
    return 'Plano $planned · nagamit $used';
  }

  @override
  String ordersWasteQty(String qty) {
    return '+$qty waste';
  }

  @override
  String ordersWasteQtyReason(String qty, String reason) {
    return '+$qty waste ($reason)';
  }

  @override
  String ordersFromStock(String qty, String price) {
    return '$qty × $price · mula sa stock';
  }

  @override
  String get ordersWasteCutting => 'Pagputol';

  @override
  String get ordersWasteDefect => 'Depekto';

  @override
  String get ordersWasteMiscount => 'Maling bilang';

  @override
  String get ordersWasteOther => 'Iba pa';

  @override
  String get ordersAdjustTitle => 'Mga nagamit na materyales';

  @override
  String get ordersAdjustIntro =>
      'I-record kung ano talaga ang nagamit mo. Ang sobra sa plano ay waste at ibabawas sa profit ng order na ito.';

  @override
  String ordersPlannedPerUnit(String qty, String price, String unit) {
    return 'Plano $qty · $price/$unit';
  }

  @override
  String ordersPlannedEach(String qty, String price) {
    return 'Plano $qty · $price bawat isa';
  }

  @override
  String ordersWasteCost(String qty, String cost) {
    return '+$qty waste · $cost';
  }

  @override
  String get ordersWhy => 'Bakit?';

  @override
  String ordersFewerThanPlanned(String qty) {
    return '$qty na mas kaunti kaysa sa plano';
  }

  @override
  String get ordersPackTitle => 'I-pack ang order na ito?';

  @override
  String get ordersPackNothing =>
      'Walang kukunin sa stock para sa order na ito.';

  @override
  String get ordersPackIntro => 'Ang mga piraso na ito ay aalisin sa shelf mo.';

  @override
  String ordersPackShort(String names) {
    return 'Kulang sa $names.';
  }

  @override
  String get ordersPackShortMessage => 'Hanggang 0 lang ang bababaan ng stock.';

  @override
  String get ordersPackConfirm => 'I-pack at ibawas';

  @override
  String get ordersAddProduct => 'Magdagdag ng produkto';

  @override
  String get ordersSearchProducts => 'Maghanap ng produkto';

  @override
  String get ordersNoProducts => 'Wala pang produkto';

  @override
  String get ordersNoProductsMessage =>
      'Magdagdag muna ng mga produkto sa More → Products.';

  @override
  String get ordersOutOfStock => 'Ubos na ang stock';

  @override
  String get ordersCantBuild => 'Hindi magagawa: kulang ang materyales';

  @override
  String ordersInStock(String qty) {
    return 'May stock na $qty';
  }

  @override
  String ordersCanBuild(String qty) {
    return 'Kayang gawin: $qty';
  }

  @override
  String get ordersAddedTag => 'Naidagdag na';

  @override
  String get ordersDiscountsCaps => 'MGA DISCOUNT';

  @override
  String get ordersManage => 'Ayusin';

  @override
  String ordersRemoveDiscount(String label) {
    return 'Alisin ang $label';
  }

  @override
  String get ordersAddDiscountChip => '+ Magdagdag ng discount';

  @override
  String get ordersOtherDiscountChip => '+ Iba pa';

  @override
  String get ordersAddDiscountTitle => 'Magdagdag ng discount';

  @override
  String ordersTaxInPrices(String tax, String rate) {
    return '$tax $rate% · kasama sa presyo';
  }

  @override
  String ordersTaxOnTop(String tax, String rate) {
    return '$tax $rate% · idinagdag sa ibabaw';
  }

  @override
  String get ordersTaxOff => 'Naka-off para sa order na ito';

  @override
  String ordersTaxPartOfTotal(String amount, String tax) {
    return '$amount ng kabuuan ay $tax';
  }

  @override
  String ordersTaxCustomerPays(String amount) {
    return 'Magbabayad ang customer ng $amount pa';
  }

  @override
  String get ordersPaidSwitch => 'Bayad na';

  @override
  String get ordersPaidHasPaid => 'Nakabayad na ang customer';

  @override
  String ordersPaidWaitingFor(String amount) {
    return 'Naghihintay ng $amount';
  }

  @override
  String get ordersPickChannel => 'Pumili ng sales channel';

  @override
  String get ordersDiscardEditTitle => 'Itatapon ang mga pagbabago mo?';

  @override
  String get ordersDiscardNewTitle => 'Itatapon ang order na ito?';

  @override
  String get ordersDiscardEditMessage =>
      'Mananatili ang order kung paano ito dati.';

  @override
  String get ordersDiscardNewMessage => 'Mawawala ang mga nailagay mo na.';

  @override
  String ordersSaved(String id) {
    return 'Na-save ang order #$id';
  }

  @override
  String ordersUpdated(String id) {
    return 'Na-update ang order #$id';
  }

  @override
  String get ordersEditTitle => 'I-edit ang order';

  @override
  String ordersEditTitleId(String id) {
    return 'I-edit ang order #$id';
  }

  @override
  String get ordersStepDetails => 'Detalye';

  @override
  String get ordersStepCustomer => 'Customer';

  @override
  String get ordersStepItems => 'Mga item';

  @override
  String get ordersStepReview => 'Suriin';

  @override
  String get ordersCustomerName => 'Pangalan ng customer';

  @override
  String get ordersEnterCustomerName => 'Ilagay ang pangalan ng customer';

  @override
  String get ordersAddOrderFields =>
      'Magdagdag ng mga order field (address, size…)';

  @override
  String get ordersChannel => 'Channel';

  @override
  String get ordersNoChannelsTitle => 'Wala pang sales channel.';

  @override
  String get ordersNoChannelsMessage =>
      'Magdagdag ng isa para makuwenta ang mga fee.';

  @override
  String get ordersOrderDate => 'Petsa ng order';

  @override
  String get ordersShipBy => 'Ipadala bago ang';

  @override
  String get ordersNoItemsTitle => 'Wala pang item';

  @override
  String get ordersNoItemsMessage =>
      'Idagdag ang mga produktong inorder ng customer na ito.';

  @override
  String ordersEachSubtotal(String price, String subtotal) {
    return '$price bawat isa · $subtotal';
  }

  @override
  String get ordersRemoveHint => 'Gawing 0 ang dami para alisin ito.';

  @override
  String ordersShipsByItems(String date, String items) {
    return 'Ipapadala bago ang $date · $items';
  }

  @override
  String get ordersShortBannerTitle => 'Kulang ang stock para sa ilang piraso.';

  @override
  String get ordersShortBannerMessage =>
      'Puwede mo pa ring i-save; ipapakita ng buy list kung ano ang bibilhin.';

  @override
  String get ordersSaving => 'Sine-save…';

  @override
  String get ordersSaveChanges => 'I-save ang mga pagbabago';

  @override
  String get ordersSaveOrder => 'I-save ang order';

  @override
  String get ordersNextAddItems => 'Susunod: magdagdag ng item';

  @override
  String get ordersReview => 'Suriin';

  @override
  String get ordersTotal => 'Kabuuan';

  @override
  String get ordersReservesCaps => 'NIRE-RESERVE MULA SA STOCK';

  @override
  String ordersOnlyFree(String qty, String free) {
    return '$qty · $free lang ang libre';
  }

  @override
  String ordersLastOne(num count, String qty) {
    return '$qty · ang huli';
  }

  @override
  String get todayToPackToday => 'I-pack ngayon';

  @override
  String get todayNewToday => 'Bago ngayon';

  @override
  String get todayWeekProfit => 'Profit ngayong linggo';

  @override
  String get todayCalendar => 'Kalendaryo';

  @override
  String todayLowStock(int count) {
    return '$count ang paubos na:';
  }

  @override
  String get todayBuyList => 'Buy list';

  @override
  String todayPinnedNotes(int count) {
    return 'Mga naka-pin na note · $count';
  }

  @override
  String get todayAllNotes => 'Lahat ng note';

  @override
  String todayShipsToday(int count) {
    return 'Ipapadala ngayon · $count';
  }

  @override
  String todayNewTodaySection(int count) {
    return 'Bago ngayon · $count';
  }

  @override
  String get todayAllClear => 'Wala nang gagawin ngayon';

  @override
  String get todayAllClearMessage =>
      'Dito lalabas ang mga order na ipapadala ngayon at ang mga bagong order.';

  @override
  String get todayNoFilterMatch => 'Walang tugma sa filter na ito';

  @override
  String get todayPickAnotherStatus =>
      'Pumili ng ibang status o pindutin ang Lahat.';

  @override
  String todayNoteDeleted(String title) {
    return 'Nabura ang $title';
  }

  @override
  String get todayPrevWeek => 'Nakaraang linggo';

  @override
  String get todayNextWeek => 'Susunod na linggo';

  @override
  String get todayPrevMonth => 'Nakaraang buwan';

  @override
  String get todayNextMonth => 'Susunod na buwan';

  @override
  String get todayWeek => 'Linggo';

  @override
  String get todayMonth => 'Buwan';

  @override
  String get todayNothingDue => 'Walang due';

  @override
  String get todayNothingShipsDay => 'Walang ipapadala sa araw na ito.';

  @override
  String todayDayOrders(String date, String orders) {
    return '$date · $orders';
  }

  @override
  String get productsInventoryTitle => 'Imbentaryo';

  @override
  String get productsTabProducts => 'Mga Produkto';

  @override
  String get productsTabMaterials => 'Mga Materyales';

  @override
  String get productsFabProduct => 'Produkto';

  @override
  String get productsFabMaterial => 'Materyales';

  @override
  String get productsTypeAny => 'Lahat';

  @override
  String get productsTypeHandmade => 'Gawang-kamay';

  @override
  String get productsTypeResell => 'Resell';

  @override
  String get productsStockAny => 'Lahat';

  @override
  String get productsStockLow => 'Paubos na';

  @override
  String get productsStockShort => 'Kulang';

  @override
  String get productsStockArchived => 'Naka-archive';

  @override
  String get productsFilterTitle => 'I-filter ang mga produkto';

  @override
  String get productsFilterSubtitle => 'Gumagana kasabay ng paghahanap.';

  @override
  String get productsFilterType => 'Uri';

  @override
  String get productsFilterStock => 'Stock';

  @override
  String get productsFilterClearAll => 'I-clear lahat';

  @override
  String get productsFilterShow => 'Ipakita';

  @override
  String get productsSearchHint => 'Maghanap ng produkto';

  @override
  String get productsEmptyTitle => 'Wala pang produkto';

  @override
  String get productsEmptyMessage =>
      'Idagdag ang mga ibinebenta mo at ang mga materyales na ginagamit dito.';

  @override
  String get productsAddProduct => 'Magdagdag ng produkto';

  @override
  String get productsNoMatches => 'Walang tugma';

  @override
  String productsNoMatchesFor(String query) {
    return 'Walang tugma sa \"$query\".';
  }

  @override
  String get productsNoFilterMatchTitle => 'Walang tugma sa mga filter na ito';

  @override
  String get productsNoFilterMatchMessage =>
      'I-tap ang filter sa itaas para alisin ito.';

  @override
  String get productsNoHandmadeTitle => 'Walang gawang-kamay na produkto';

  @override
  String get productsNoHandmadeMessage =>
      'Dito lalabas ang mga produktong gawa mula sa iyong mga materyales.';

  @override
  String get productsNoResellTitle => 'Walang resell na produkto';

  @override
  String get productsNoResellMessage =>
      'Dito lalabas ang mga binibili mong yari na at ibinebenta mo ulit.';

  @override
  String get productsAllArchivedTitle => 'Naka-archive ang lahat ng produkto';

  @override
  String get productsAllArchivedMessage =>
      'I-filter ang Naka-archive para makita ang mga ito.';

  @override
  String get productsNothingLowTitle => 'Walang paubos na';

  @override
  String get productsNothingLowMessage =>
      'Magtakda ng warning level sa produkto para mabantayan ito dito.';

  @override
  String get productsActionEdit => 'I-edit ang produkto';

  @override
  String get productsActionReceive => 'Tumanggap ng stock';

  @override
  String get productsActionDelete => 'I-delete ang produkto';

  @override
  String productsArchivedSnack(String name) {
    return 'Na-archive ang $name';
  }

  @override
  String productsUnarchivedSnack(String name) {
    return 'Nasa mga listahan mo na ulit ang $name';
  }

  @override
  String productsDeleteTitle(String name) {
    return 'I-delete ang $name?';
  }

  @override
  String get productsDeleteMessage =>
      'Hindi na ito mababawi. Hindi puwedeng i-delete ang mga produktong may order; i-archive na lang ang mga ito.';

  @override
  String get productsDeletedSnack => 'Na-delete ang produkto';

  @override
  String get productsTagResell => 'Resell';

  @override
  String get productsTagArchived => 'Naka-archive';

  @override
  String get productsTagShortForOrders => 'Kulang para sa mga order';

  @override
  String productsCardCost(String cost) {
    return 'Puhunan $cost';
  }

  @override
  String productsCardMargin(String percent) {
    return '$percent% margin';
  }

  @override
  String get productsInStock => 'Nasa stock';

  @override
  String get productsCanBuild => 'Kayang gawin';

  @override
  String productsPhotoOf(String name) {
    return 'Larawan ng $name';
  }

  @override
  String get productsOnHandCaps => 'NASA STOCK';

  @override
  String productsUnitOnHandCaps(String unit) {
    return '$unit ANG NASA STOCK';
  }

  @override
  String get productsCanBuildCaps => 'KAYANG GAWIN';

  @override
  String get productsStatShort => 'Kulang';

  @override
  String get productsStatFree => 'Libre';

  @override
  String get productsStatPromised => 'Nakareserba';

  @override
  String get productsStatReorderAt => 'Mag-reorder sa';

  @override
  String get productsStatWarnAt => 'Mag-warn sa';

  @override
  String get productsStatSellPrice => 'Presyo';

  @override
  String get productsStatCost => 'Puhunan';

  @override
  String get productsStatMargin => 'Margin';

  @override
  String get productsProfitPerItem => 'KITA BAWAT ITEM';

  @override
  String productsProfitPerUnit(String unit) {
    return 'KITA BAWAT $unit';
  }

  @override
  String productsProfitNote(String cost, String kind, String margin) {
    String _temp0 = intl.Intl.selectLogic(
      kind,
      {
        'resell': 'puhunan',
        'other': 'materyales',
      },
    );
    return '$cost $_temp0 · $margin% margin · bago ang fees ng channel';
  }

  @override
  String get productsPhotoTitle => 'Larawan ng produkto';

  @override
  String get productsPhotoSubtitle =>
      'Makikita ito kapag pumipili ka ng produkto para sa order.';

  @override
  String get productsPhotoTake => 'Kumuha ng litrato';

  @override
  String get productsPhotoGallery => 'Pumili sa gallery';

  @override
  String get productsPhotoRemove => 'Alisin ang litrato';

  @override
  String get productsPhotoCameraFailed => 'Hindi mabuksan ang camera';

  @override
  String get productsPhotoGalleryFailed => 'Hindi mabuksan ang mga litrato mo';

  @override
  String get productsPhotoAdd => 'Magdagdag ng litrato';

  @override
  String get productsPhotoChange => 'Palitan ang litrato';

  @override
  String get productsPhotoHelp =>
      'Para madaling makita ang tamang item kapag gumagawa ng order.';

  @override
  String get productsHistInitial => 'Unang stock';

  @override
  String get productsHistReturned => 'Ibinalik mula sa na-delete na order';

  @override
  String get productsHistReceived => 'Natanggap';

  @override
  String get productsHistUsed => 'Nagamit sa order';

  @override
  String get productsHistCounted => 'Binilang';

  @override
  String get productsNotFound => 'Hindi nahanap ang produkto';

  @override
  String get productsCountTitle => 'Bilangin ang stock';

  @override
  String get productsCountSubtitle =>
      'Itakda kung ilan talaga ang nasa estante.';

  @override
  String get productsCountSave => 'I-save ang bilang';

  @override
  String productsStockSet(String qty) {
    return 'Naitakda ang stock sa $qty';
  }

  @override
  String get productsReceive => 'Tumanggap';

  @override
  String get productsCount => 'Bilangin';

  @override
  String productsMaterialsPerItem(String count) {
    return 'Materyales bawat item · $count';
  }

  @override
  String productsMaterialsPerUnit(String unit, String count) {
    return 'Materyales bawat $unit · $count';
  }

  @override
  String get productsNoMaterialsYet =>
      'Wala pang materyales. I-edit ang produkto para magdagdag.';

  @override
  String productsMakesCount(String makes) {
    return 'gumagawa ng $makes';
  }

  @override
  String get productsHistoryTitle => 'Kasaysayan';

  @override
  String productsHistoryError(String error) {
    return 'Hindi ma-load ang kasaysayan: $error';
  }

  @override
  String get productsHistoryEmpty => 'Wala pang benta o pagbabago sa stock.';

  @override
  String get productsReceiveCaps => 'TUMANGGAP';

  @override
  String get productsQuantityReceivedCaps => 'BILANG NA NATANGGAP';

  @override
  String get productsPriceEach => 'Presyo bawat isa';

  @override
  String productsPricePerUnit(String unit) {
    return 'Presyo bawat $unit';
  }

  @override
  String get productsAfterReceivingCaps => 'PAGKATAPOS TUMANGGAP';

  @override
  String get productsUnitCostWeighted => 'Puhunan bawat isa (average)';

  @override
  String productsReceivedSnack(String qty, String name) {
    return 'Nadagdag ang $qty sa $name';
  }

  @override
  String productsReceiveButton(String qty) {
    return 'Idagdag ang $qty sa stock';
  }

  @override
  String get productsNewProduct => 'Bagong produkto';

  @override
  String get productsEditProduct => 'I-edit ang produkto';

  @override
  String get productsEnterName => 'Maglagay ng pangalan';

  @override
  String get productsDescriptionOptional => 'Paglalarawan (opsyonal)';

  @override
  String get productsPriceAboveZero => 'Maglagay ng presyong higit sa 0';

  @override
  String get productsSoldCountedIn => 'Ibinebenta at binibilang sa';

  @override
  String get productsLockOrders =>
      'May order na ito, kaya hindi na mapapalitan ang uri.';

  @override
  String get productsLockStock =>
      'May stock o reserba na ito, kaya hindi na mapapalitan ang uri.';

  @override
  String get productsLockBom =>
      'Alisin muna ang mga materyales nito para gawing Resell.';

  @override
  String get productsTypeHintResell =>
      'Binili nang yari. May sarili itong stock.';

  @override
  String get productsTypeHintHandmade =>
      'Gawa mula sa mga materyales. Ang stock ay base sa kaya mong gawin.';

  @override
  String get productsSaving => 'Sine-save…';

  @override
  String get productsSaveChanges => 'I-save ang mga pagbabago';

  @override
  String productsAddedSnack(String name) {
    return 'Naidagdag ang $name';
  }

  @override
  String get productsChangesSaved => 'Na-save ang mga pagbabago';

  @override
  String productsMakesAboveZero(String material) {
    return '$material: Dapat higit sa 0 ang Makes';
  }

  @override
  String get productsCostPerItem => 'Puhunan bawat item';

  @override
  String productsCostPerUnit(String unit) {
    return 'Puhunan bawat $unit';
  }

  @override
  String get productsMaterialsPerItemLabel => 'Materyales bawat item';

  @override
  String productsMaterialsPerUnitLabel(String unit) {
    return 'Materyales bawat $unit';
  }

  @override
  String get productsAddMaterialTitle => 'Magdagdag ng materyales';

  @override
  String get productsNoMaterialsTitle => 'Wala pang materyales';

  @override
  String get productsAllMaterialsAdded =>
      'Naidagdag na ang lahat ng materyales';

  @override
  String get productsAddMaterialsFirst =>
      'Magdagdag muna ng materyales sa Stock.';

  @override
  String get productsSearchMaterials => 'Maghanap ng materyales';

  @override
  String get productsAddMaterialsHint =>
      'Idagdag kung saan ito gawa para makuwenta ng app ang puhunan at makapag-reserba ng stock.';

  @override
  String productsCostEach(String cost) {
    return '$cost bawat isa';
  }

  @override
  String get productsUses => 'Gamit';

  @override
  String get productsMakes => 'Nagagawa';

  @override
  String get productsBomHelp =>
      'Ang Gamit ay kung gaano karami ng materyales ang ginagamit, ang Nagagawa ay kung ilang produkto ang nabubuo nito (1 sheet = 9 card). Gawing 0 ang Gamit para alisin ang materyales.';

  @override
  String get productsReorderAtOptional => 'Mag-reorder sa (opsyonal)';

  @override
  String get productsWarnWhenCanMake =>
      'I-warn kapag kaya ko nang gumawa ng (opsyonal)';

  @override
  String get productsReorderHelp =>
      'I-warn kapag bumaba ang stock sa bilang na ito.';

  @override
  String get productsWarnHelp =>
      'I-warn kapag ito na lang ang kaya ng mga materyales.';

  @override
  String get productsStockSection => 'Stock';

  @override
  String get productsCostRecalc =>
      'Kapag may natanggap na stock, ire-recompute ito bilang average.';

  @override
  String get productsOnHandNow => 'Nasa stock ngayon';

  @override
  String get productsChannelsTitle => 'Mga channel at fees';

  @override
  String get productsChannelAdded => 'Naidagdag ang channel';

  @override
  String get productsChannelDeleted => 'Na-delete ang channel';

  @override
  String get productsChannelsEmptyTitle => 'Wala pang channel';

  @override
  String get productsChannelsEmptyMessage =>
      'Idagdag ang Shopee, TikTok Shop, walk-in… kasama ang fees nila para tama ang kita.';

  @override
  String get productsChannelAddButton => 'Magdagdag ng channel';

  @override
  String productsChannelsNote(String sale) {
    return 'Ang mga halimbawa ay base sa $sale na benta. Nananatili sa mga lumang order ang mga naka-off na channel pero nakatago ito kapag gumagawa ng bagong order.';
  }

  @override
  String get productsChannelFab => 'Channel';

  @override
  String get productsChannelEdit => 'I-edit ang channel';

  @override
  String get productsChannelDelete => 'I-delete ang channel';

  @override
  String get productsChannelTurnOff => 'I-off';

  @override
  String get productsChannelTurnOn => 'I-on';

  @override
  String productsChannelDeleteTitle(String name) {
    return 'I-delete ang $name?';
  }

  @override
  String get productsChannelDeleteMessage =>
      'Hindi puwedeng i-delete ang mga channel na may order. I-off na lang ang mga ito.';

  @override
  String get productsChannelNew => 'Bagong channel';

  @override
  String productsChannelEditTitle(String name) {
    return 'I-edit ang $name';
  }

  @override
  String get productsChannelNameHint => 'hal. Shopee';

  @override
  String get productsChannelCommission => 'Komisyon';

  @override
  String get productsChannelTransactionFee => 'Transaction fee';

  @override
  String get productsChannelFixedFee => 'Fixed fee';

  @override
  String get productsChannelShippingYouPay => 'Shipping na ikaw ang nagbabayad';

  @override
  String get productsChannelPaidWhenPlaced => 'Bayad na ang order pag-order';

  @override
  String get productsChannelPaidUpfront =>
      'Tulad ng marketplace na naniningil agad';

  @override
  String get productsChannelUnpaidStart =>
      'Hindi pa bayad ang mga bagong order, para sa COD o benta sa chat';

  @override
  String productsChannelYouKeep(String sale) {
    return 'Sa $sale na benta, ang matitira sa iyo ay';
  }

  @override
  String get productsChannelBeforeMaterials => 'bago ang materyales.';

  @override
  String get productsChannelNoFees => 'Walang fees';

  @override
  String productsChannelRecipeShipping(String fees, String shipping) {
    return '$fees · ikaw ang bahala sa $shipping na shipping';
  }

  @override
  String productsChannelHiddenKeep(String sale) {
    return 'Nakatago sa mga bagong order · sa $sale na benta, ang matitira sa iyo ay';
  }

  @override
  String get unitsTitle => 'Mga unit ng sukat';

  @override
  String get unitsEmptyTitle => 'Wala pang unit';

  @override
  String get unitsEmptyMessage =>
      'Idagdag ang mga ginagamit mong pambilang, tulad ng pc, sheet o kg.';

  @override
  String get unitsAddButton => 'Magdagdag ng unit';

  @override
  String get unitsFab => 'Unit';

  @override
  String get unitsNew => 'Bagong unit';

  @override
  String unitsEditTitle(String label) {
    return 'I-edit ang $label';
  }

  @override
  String get unitsDefaultNote => 'Ito ang gagamitin ng mga bagong item';

  @override
  String get unitsActionEdit => 'I-edit ang unit';

  @override
  String get unitsActionUseForNew => 'Gamitin sa mga bagong item';

  @override
  String unitsDeleteTitle(String label) {
    return 'I-delete ang $label?';
  }

  @override
  String get unitsDeleteMessage =>
      'Nananatili ang bilang ng mga materyales at produktong gumagamit nito, kaya ilipat muna ang mga ito sa ibang unit.';

  @override
  String get unitsDefaultTag => 'Default';

  @override
  String get unitsDragToReorder => 'I-drag para ayusin ang pagkakasunod';

  @override
  String get unitsFooter =>
      'Ang lahat ng binibilang mo ay isinusulat gamit ang isa sa mga ito: stock, gamit ng produkto, reserba ng order. Pindutin nang matagal ang isa para palitan ang pangalan, gawing default sa mga bagong item, o i-delete.';

  @override
  String get unitsPickerSubtitle =>
      'Ito ang gagamitin sa lahat ng bilang nito.';

  @override
  String get unitsPickerHelper =>
      'Magdagdag pa sa Higit pa → Mga unit ng sukat';

  @override
  String get unitsFieldLabel => 'Unit';

  @override
  String get unitsFieldHint => 'hal. sheet, board, kg';

  @override
  String get unitsFieldHelper =>
      'Ipinapakita nang eksakto ayon sa tina-type mo, kaya tama pa rin ang pinaikling tulad ng kg o m.';

  @override
  String get unitsNameRequired => 'Pangalanan ang unit';

  @override
  String unitsTooLong(String max) {
    return 'Panatilihing wala pang $max na character — lumalabas ito sa tabi ng bawat bilang';
  }

  @override
  String get discountsTitle => 'Mga diskwento';

  @override
  String get discountsEmptyTitle => 'Wala pang diskwento';

  @override
  String get discountsEmptyMessage =>
      'I-save ang mga madalas mong ibigay, tulad ng 10% para sa suki. Puwede ka pa ring maglagay ng kahit anong diskwento sa order.';

  @override
  String get discountsAddButton => 'Magdagdag ng diskwento';

  @override
  String get discountsFab => 'Diskwento';

  @override
  String get discountsNew => 'Bagong diskwento';

  @override
  String discountsEditTitle(String label) {
    return 'I-edit ang $label';
  }

  @override
  String get discountsActionEdit => 'I-edit ang diskwento';

  @override
  String discountsDeleteTitle(String label) {
    return 'I-delete ang $label?';
  }

  @override
  String get discountsDeleteMessage =>
      'Mananatili ito sa mga order na mayroon na nito.';

  @override
  String get discountsDragToReorder => 'I-drag para ayusin ang pagkakasunod';

  @override
  String get discountsFooter =>
      'Lalabas ang mga ito bilang one-tap chips kapag nire-review ang order. May sariling kopya ang bawat order, kaya hindi nagbabago ang mga lumang order kapag in-edit ito dito.';

  @override
  String get discountsNameHint => 'hal. Suki';

  @override
  String get discountsKindPercent => 'Porsyento';

  @override
  String get discountsKindFixed => 'Takdang halaga';

  @override
  String get discountsPercentOff => 'Porsyentong bawas';

  @override
  String get discountsAmountOff => 'Halagang bawas';

  @override
  String get discountsPercentHelper =>
      'Ibabawas sa kabuuang halaga ng mga item';

  @override
  String get discountsFixedHelper => 'Isang beses ibabawas sa order';

  @override
  String get discountsNameRequired => 'Pangalanan ang diskwento';

  @override
  String get discountsAmountRequired => 'Maglagay ng halagang higit sa zero';

  @override
  String get discountsPercentMax => 'Hanggang 100 lang ang porsyento';

  @override
  String get stockActionReceive => 'Tumanggap ng stock';

  @override
  String get stockActionEdit => 'I-edit ang materyales';

  @override
  String get stockActionDelete => 'Burahin ang materyales';

  @override
  String stockArchivedSnack(String name) {
    return 'Na-archive ang $name';
  }

  @override
  String stockUnarchivedSnack(String name) {
    return 'Nasa mga listahan mo na ulit ang $name';
  }

  @override
  String stockDeleteTitle(String name) {
    return 'Burahin ang $name?';
  }

  @override
  String get stockDeleteBody =>
      'Hindi na ito mababawi. Hindi mabubura ang materyales na ginagamit sa produkto o order; i-archive na lang ito.';

  @override
  String stockDeleteOnHand(String quantity) {
    return 'May natitira ka pang $quantity. Mabubura rin ang kasaysayan ng stock nito.';
  }

  @override
  String stockDeletedSnack(String name) {
    return 'Nabura ang $name';
  }

  @override
  String get stockFilterAny => 'Lahat';

  @override
  String get stockFilterLow => 'Paubos na';

  @override
  String get stockFilterPromised => 'May nakareserba';

  @override
  String get stockFilterArchived => 'Naka-archive';

  @override
  String get stockFilterTitle => 'I-filter ang mga materyales';

  @override
  String get stockFilterSubtitle => 'Gumagana kasabay ng paghahanap.';

  @override
  String get stockFilterStock => 'Stock';

  @override
  String get stockFilterClear => 'Alisin lahat';

  @override
  String get stockFilterShow => 'Ipakita';

  @override
  String get stockArchivedTag => 'Naka-archive';

  @override
  String stockCardFree(String quantity) {
    return '$quantity libre';
  }

  @override
  String stockCardPromised(String quantity) {
    return '$quantity nakareserba';
  }

  @override
  String stockCardReorderAt(String quantity) {
    return 'mag-reorder sa $quantity';
  }

  @override
  String stockCardShort(String quantity) {
    return 'kulang ng $quantity';
  }

  @override
  String get stockBuyListButton => 'Bibilhin';

  @override
  String stockBuyListButtonCount(int count) {
    return 'Bibilhin · $count';
  }

  @override
  String get stockSearchHint => 'Maghanap ng materyales';

  @override
  String get stockEmptyNoneTitle => 'Wala pang materyales';

  @override
  String get stockEmptyNoneMessage =>
      'Idagdag ang mga butil, sinulid, at kahon na ginagamit sa mga produkto mo.';

  @override
  String get stockAddMaterial => 'Magdagdag ng materyales';

  @override
  String get stockEmptyNoMatchTitle => 'Walang tugma';

  @override
  String stockEmptyNoMatchMessage(String query) {
    return 'Walang tumutugma sa \"$query\".';
  }

  @override
  String get stockEmptyAllArchivedTitle => 'Naka-archive lahat ng materyales';

  @override
  String get stockEmptyAllArchivedMessage =>
      'I-filter ng Naka-archive para makita ang mga ito.';

  @override
  String get stockEmptyNotLowTitle => 'Walang paubos na';

  @override
  String get stockEmptyNotLowMessage =>
      'Lahat ng materyales ay lampas sa reorder level.';

  @override
  String get stockEmptyNoPromisedTitle => 'Walang nakareserba';

  @override
  String get stockEmptyNoPromisedMessage =>
      'Dito lalabas ang mga materyales na nakareserba sa mga bukas na order.';

  @override
  String get stockMaterialNotFound => 'Hindi nakita ang materyales';

  @override
  String get stockReceiveCaption => 'TANGGAPIN';

  @override
  String get stockReceiveEnterPrice =>
      'Ilagay kung magkano ang bayad mo bawat pack';

  @override
  String stockReceiveAdded(String quantity, String name) {
    return 'Nadagdag ang $quantity ng $name';
  }

  @override
  String get stockReceivePacksCaption => 'MGA PACK NA NATANGGAP';

  @override
  String stockReceivePerPack(String quantity) {
    return '$quantity bawat pack';
  }

  @override
  String get stockReceivePriceLabel => 'Presyo bawat pack';

  @override
  String get stockSupplierOptional => 'Supplier (opsyonal)';

  @override
  String get stockReceiveAfterCaption => 'PAGKATAPOS TUMANGGAP';

  @override
  String get stockReceiveUnitCost => 'Gastos bawat piraso (average)';

  @override
  String get stockReceiveCostUp =>
      'Medyo tataas ang gastos sa paggawa ng mga produktong gumagamit nito.';

  @override
  String stockReceiveAddButton(String quantity) {
    return 'Idagdag ang $quantity sa stock';
  }

  @override
  String stockPacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pack',
    );
    return '$_temp0';
  }

  @override
  String get stockBuyListTitle => 'Bibilhin';

  @override
  String get stockBuyListCopyHeader => 'Listahan ng bibilhin sa CraftBook';

  @override
  String stockBuyListCopyLine(String name, String amount, String cost) {
    return '- $name: $amount, $cost';
  }

  @override
  String stockBuyListCopyTotal(String total) {
    return 'Kabuuan: $total';
  }

  @override
  String get stockBuyListCopied => 'Nakopya ang listahan ng bibilhin';

  @override
  String get stockBuyEmptyTitle => 'Walang bibilhin';

  @override
  String get stockBuyEmptyMessage => 'Lahat ay lampas sa reorder level.';

  @override
  String stockBuyItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item',
    );
    return '$_temp0';
  }

  @override
  String get stockBuyCopyList => 'Kopyahin ang listahan';

  @override
  String get stockBuyTagResell => 'Ibinebenta ulit';

  @override
  String stockBuyTagBlocking(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Humaharang sa $count order',
    );
    return '$_temp0';
  }

  @override
  String get stockBuyTagOutOfFree => 'Ubos na ang libreng stock';

  @override
  String get stockBuyTagBelowReorder => 'Mababa sa reorder';

  @override
  String get stockBuyVerb => 'Bumili ng';

  @override
  String stockBuyFreeNow(String quantity) {
    return '$quantity libre ngayon';
  }

  @override
  String stockBuyHoldsUp(String products) {
    return 'Naaantala: $products';
  }

  @override
  String get stockCountTitle => 'Bilangin ang stock';

  @override
  String get stockCountSubtitle => 'Ilagay ang totoong bilang sa estante.';

  @override
  String stockCountMatches(String quantity) {
    return 'Pareho sa app ($quantity)';
  }

  @override
  String stockCountDiff(String change, String quantity) {
    return '$change mula sa $quantity sa app';
  }

  @override
  String get stockCountSave => 'I-save ang bilang';

  @override
  String stockCountSet(String quantity) {
    return 'Naitakda ang stock sa $quantity';
  }

  @override
  String get stockOnHandCaption => 'NATITIRA';

  @override
  String stockUnitOnHandCaption(String unit) {
    return '$unit NATITIRA';
  }

  @override
  String get stockStatShort => 'Kulang';

  @override
  String get stockStatFree => 'Libre';

  @override
  String get stockStatPromised => 'Nakareserba';

  @override
  String get stockStatReorderAt => 'Mag-reorder sa';

  @override
  String get stockStatUnitCost => 'Gastos bawat piraso';

  @override
  String get stockStatPack => 'Pack';

  @override
  String get stockStatSupplier => 'Supplier';

  @override
  String get stockReceive => 'Tumanggap';

  @override
  String get stockCount => 'Bilangin';

  @override
  String stockUsedIn(int count) {
    return 'Ginagamit sa · $count';
  }

  @override
  String get stockUsedInEmpty => 'Hindi pa bahagi ng anumang produkto.';

  @override
  String get stockHistory => 'Kasaysayan';

  @override
  String get stockHistoryEmpty => 'Wala pang pagbabago sa stock.';

  @override
  String stockUsagePer(String quantity, String makes) {
    return '$quantity bawat $makes';
  }

  @override
  String stockUsageEach(String quantity) {
    return '$quantity bawat isa';
  }

  @override
  String get stockMoveReturned => 'Ibinalik mula sa binurang order';

  @override
  String get stockMoveReceived => 'Natanggap';

  @override
  String get stockMoveUsed => 'Nagamit sa order';

  @override
  String get stockMoveCounted => 'Binilang';

  @override
  String get stockMoveWaste => 'Nasayang';

  @override
  String get stockNewTitle => 'Bagong materyales';

  @override
  String get stockNameHint => 'hal. Glass seed beads 2mm';

  @override
  String get stockNameRequired => 'Maglagay ng pangalan';

  @override
  String get stockCountedIn => 'Binibilang sa';

  @override
  String get stockSectionBuy => 'Paano mo ito binibili';

  @override
  String get stockPerPackLabel => 'Bawat pack';

  @override
  String stockUnitPerPackLabel(String unit) {
    return '$unit bawat pack';
  }

  @override
  String get stockPackPrice => 'Presyo ng pack';

  @override
  String get stockPriceRequired => 'Maglagay ng presyo';

  @override
  String stockCostPerUnit(String cost, String unit) {
    return '$cost bawat $unit';
  }

  @override
  String get stockSectionStock => 'Stock';

  @override
  String get stockOnHandNow => 'Natitira ngayon';

  @override
  String stockUnitOnHandNow(String unit) {
    return '$unit natitira ngayon';
  }

  @override
  String get stockReorderHelp =>
      'Makakakita ka ng babala at mapupunta ito sa listahan ng bibilhin kapag bumaba ang stock sa reorder level.';

  @override
  String get stockNumberAboveZero => 'Maglagay ng numerong higit sa 0';

  @override
  String get stockNumberZeroOrMore => 'Maglagay ng 0 o higit pa';

  @override
  String get stockSaving => 'Sine-save…';

  @override
  String get stockSaveChanges => 'I-save ang mga pagbabago';

  @override
  String stockAdded(String name) {
    return 'Naidagdag ang $name';
  }

  @override
  String stockUpdated(String name) {
    return 'Na-update ang $name';
  }
}
