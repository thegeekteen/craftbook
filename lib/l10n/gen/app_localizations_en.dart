// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CraftBook';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'The language the app is shown in.';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFilipino => 'Filipino (Tagalog)';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDone => 'Done';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonClose => 'Close';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonArchive => 'Archive';

  @override
  String get commonUnarchive => 'Unarchive';

  @override
  String get commonRestore => 'Restore';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonAll => 'All';

  @override
  String get commonNone => 'None';

  @override
  String get commonOn => 'On';

  @override
  String get commonOff => 'Off';

  @override
  String get commonName => 'Name';

  @override
  String get commonNotes => 'Notes';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonLow => 'Low';

  @override
  String get commonFilter => 'Filter';

  @override
  String get commonNotSet => 'Not set';

  @override
  String commonClearField(String label) {
    return 'Clear $label';
  }

  @override
  String get commonCouldntLoad => 'Couldn’t load this';

  @override
  String get navToday => 'Today';

  @override
  String get navOrders => 'Orders';

  @override
  String get navInventory => 'Inventory';

  @override
  String get navReports => 'Reports';

  @override
  String get navMore => 'More';

  @override
  String get dateToday => 'Today';

  @override
  String get dateTomorrow => 'Tomorrow';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String dateInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count days',
      one: 'In 1 day',
    );
    return '$_temp0';
  }

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get moneySales => 'Sales';

  @override
  String get moneyDiscounts => 'Discounts';

  @override
  String get moneyTax => 'Tax';

  @override
  String moneyTaxInPrices(String tax) {
    return '$tax in prices';
  }

  @override
  String get moneyMaterials => 'Materials';

  @override
  String get moneyChannelFees => 'Channel fees';

  @override
  String get moneyShipping => 'Shipping';

  @override
  String moneyAddedTaxNote(String amount, String tax) {
    return '+ $amount $tax added for the customer to pay. It isn’t yours, so it’s not in profit.';
  }

  @override
  String moneyProfitMargin(int margin) {
    return 'Profit · $margin% margin';
  }

  @override
  String moneyProfitSemantics(String profit, String sales) {
    return 'Profit $profit of $sales sales';
  }

  @override
  String get pipFree => 'free';

  @override
  String get pipPromised => 'promised';

  @override
  String get pipReorderLevel => 'reorder level';

  @override
  String productPhotoOf(String name) {
    return 'Photo of $name';
  }

  @override
  String get appLogoLabel => 'CraftBook logo';

  @override
  String get noteToolRedo => 'Redo';

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
  String get noteToolHighlight => 'Highlight';

  @override
  String get noteToolLargeHeading => 'Large heading';

  @override
  String get noteToolHeading => 'Heading';

  @override
  String get noteToolSmallHeading => 'Small heading';

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
  String get noteToolOutdent => 'Outdent';

  @override
  String get noteToolIndent => 'Indent';

  @override
  String get noteToolAlignCentre => 'Align centre';

  @override
  String get noteToolAlignRight => 'Align right';

  @override
  String get noteToolLink => 'Link';

  @override
  String get noteToolClearFormatting => 'Clear formatting';

  @override
  String get noteLinkAdd => 'Add link';

  @override
  String get noteLinkEdit => 'Edit link';

  @override
  String get noteLinkAddress => 'Address';

  @override
  String get noteLinkRemove => 'Remove link';

  @override
  String get noteHighlightSand => 'Sand';

  @override
  String get noteHighlightGreen => 'Green';

  @override
  String get noteHighlightLavender => 'Lavender';

  @override
  String get noteHighlightRose => 'Rose';

  @override
  String get backupProblemNotSqlite => 'This isn’t a Craftbook backup file.';

  @override
  String get backupProblemCorrupt =>
      'This backup is damaged and can’t be restored.';

  @override
  String get backupProblemWrongApp =>
      'This file belongs to a different app, not Craftbook.';

  @override
  String get backupProblemNewerVersion =>
      'This backup was made with a newer Craftbook. Update the app first.';

  @override
  String get backupProblemUpgradeFailed =>
      'This backup couldn’t be upgraded to this version of Craftbook.';

  @override
  String get backupProblemSchemaMismatch =>
      'This backup is missing data Craftbook needs.';

  @override
  String get backupSaveDialogTitle => 'Save backup';

  @override
  String get backupSaved => 'Backup saved successfully';

  @override
  String backupExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get backupPickDialogTitle => 'Select backup file';

  @override
  String get backupRestoreTitle => 'Restore this backup?';

  @override
  String backupRestoreMessage(String summary) {
    return '$summary\n\nEverything on this phone is replaced by it. You can undo this from More.';
  }

  @override
  String backupContents(int orders, int materials, int products) {
    String _temp0 = intl.Intl.pluralLogic(
      orders,
      locale: localeName,
      other: '$orders orders',
      one: '1 order',
    );
    String _temp1 = intl.Intl.pluralLogic(
      materials,
      locale: localeName,
      other: '$materials materials',
      one: '1 material',
    );
    String _temp2 = intl.Intl.pluralLogic(
      products,
      locale: localeName,
      other: '$products products',
      one: '1 product',
    );
    return '$_temp0, $_temp1 and $_temp2.';
  }

  @override
  String backupContentsUpgraded(String contents) {
    return '$contents It was made with an older Craftbook and has been upgraded.';
  }

  @override
  String get backupRestored => 'Backup restored';

  @override
  String backupRestoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get backupUndoTitle => 'Undo last restore?';

  @override
  String get backupUndoMessage =>
      'Goes back to the data you had before the last restore. Anything changed since then is lost.';

  @override
  String get backupUndoConfirm => 'Undo restore';

  @override
  String backupCantUndo(String reason) {
    return 'Can’t undo: $reason';
  }

  @override
  String get backupRestoreUndone => 'Restore undone';

  @override
  String backupUndoFailed(String error) {
    return 'Undo failed: $error';
  }

  @override
  String backupSwapFailed(String error) {
    return 'Restore failed, nothing was changed: $error';
  }

  @override
  String backupRestartApp(String message) {
    return '$message. Restart the app.';
  }

  @override
  String get settingsMoreTitle => 'More';

  @override
  String get settingsSectionNotebook => 'Notebook';

  @override
  String get settingsSectionShopOnline => 'Your shop online';

  @override
  String get settingsSectionCatalogue => 'Catalogue';

  @override
  String get settingsSectionMoneyOrders => 'Money & orders';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionYourData => 'Your data';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsNotesTitle => 'Notes';

  @override
  String get settingsNotesHint => 'Supplier details, ideas, how-tos';

  @override
  String get settingsSocialTitle => 'Social shortcuts';

  @override
  String get settingsSocialHint => 'Facebook, TikTok, Shopee, Lazada…';

  @override
  String get settingsChannelsTitle => 'Channels & fees';

  @override
  String get settingsChannelsHint => 'Where you sell and what they charge';

  @override
  String get settingsOrderFieldsTitle => 'Order fields';

  @override
  String get settingsOrderFieldsHint => 'Extra details to note on each order';

  @override
  String get settingsUnitsTitle => 'Units of measure';

  @override
  String get settingsUnitsHint => 'What you count things in';

  @override
  String get settingsBuyListTitle => 'Buy list';

  @override
  String get settingsBuyListHint => 'Things to restock';

  @override
  String get settingsReceivablesTitle => 'Waiting for payment';

  @override
  String get settingsReceivablesHint => 'Everyone has paid';

  @override
  String get settingsCurrencyTitle => 'Currency';

  @override
  String get settingsTaxTitle => 'Tax';

  @override
  String get settingsDiscountsTitle => 'Discounts';

  @override
  String get settingsDiscountsHint => 'Ones you give often';

  @override
  String get settingsExportTitle => 'Export backup';

  @override
  String get settingsExportHint => 'Save a copy of everything to a file';

  @override
  String get settingsRestoreTitle => 'Restore from backup';

  @override
  String get settingsRestoreHint => 'Replaces everything on this phone';

  @override
  String get settingsUndoRestoreTitle => 'Undo last restore';

  @override
  String get settingsUndoRestoreHint => 'Go back to the data from before it';

  @override
  String get settingsAboutTitle => 'About Craftbook';

  @override
  String get settingsAboutHint => 'What it does and how to use it';

  @override
  String settingsFooterWithVersion(String version) {
    return 'Version $version · all data stays on this phone';
  }

  @override
  String get settingsFooter => 'All data stays on this phone';

  @override
  String settingsChannelsOn(int on) {
    return '$on on';
  }

  @override
  String settingsChannelsOnOff(int on, int off) {
    return '$on on · $off off';
  }

  @override
  String settingsFieldsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fields',
      one: '1 field',
    );
    return '$_temp0';
  }

  @override
  String settingsArchivedCount(int count) {
    return '$count archived';
  }

  @override
  String get settingsNothingToBuy => 'Nothing to buy';

  @override
  String settingsItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String settingsNotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
    );
    return '$_temp0';
  }

  @override
  String settingsPinnedCount(int count) {
    return '$count pinned';
  }

  @override
  String settingsOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
    );
    return '$_temp0';
  }

  @override
  String settingsShortcutsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shortcuts',
      one: '1 shortcut',
    );
    return '$_temp0';
  }

  @override
  String settingsUnitsSummary(int count, String unit) {
    return '$count · new items start on $unit';
  }

  @override
  String settingsTaxSummary(String label, String rate, String mode) {
    return '$label $rate% · $mode';
  }

  @override
  String get settingsTaxInPrices => 'in prices';

  @override
  String get settingsTaxAddedOnTop => 'added on top';

  @override
  String get settingsTaxOffByDefault => 'off by default';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutLoadFailed => 'Couldn’t load the guide. Please try again.';

  @override
  String get appearanceColourScheme => 'Colour scheme';

  @override
  String appearanceColourSchemeLabel(String name) {
    return '$name colour scheme';
  }

  @override
  String get appearancePaletteForest => 'Forest';

  @override
  String get appearancePaletteBerry => 'Berry';

  @override
  String get appearancePaletteOcean => 'Ocean';

  @override
  String get appearancePaletteSunset => 'Sunset';

  @override
  String get appearanceDarkMode => 'Dark mode';

  @override
  String get appearanceDarkAutoHint => 'Auto follows your phone';

  @override
  String get appearanceDarkOverrideHint => 'Overrides your phone setting';

  @override
  String get appearanceAuto => 'Auto';

  @override
  String get appearanceOrderCardsShow => 'Order cards show';

  @override
  String get appearanceShowsTotalHint => 'What the customer pays';

  @override
  String get appearanceShowsProfitHint => 'What you keep after costs';

  @override
  String get appearanceTotal => 'Total';

  @override
  String get appearanceProfit => 'Profit';

  @override
  String get taxSheetTitle => 'Tax';

  @override
  String get taxSheetSubtitle =>
      'Works out the tax on each order so you know what to set aside.';

  @override
  String taxExampleIncluded(String price, String tax, String name) {
    return 'A $price sale includes $tax $name. That comes out of your profit.';
  }

  @override
  String taxExampleOnTop(String price, String total, String tax, String name) {
    return 'A $price sale costs the customer $total. The $tax $name is theirs to pay, so it isn’t counted as profit.';
  }

  @override
  String get taxUse => 'Use tax';

  @override
  String get taxUseOnHint => 'Each order gets a tax switch';

  @override
  String get taxUseOffHint =>
      'Orders have no tax. Saved orders keep what they had';

  @override
  String get taxNewOrders => 'New orders start with tax';

  @override
  String get taxNewOrdersOnHint => 'Switch it off on orders that don’t need it';

  @override
  String get taxNewOrdersOffHint =>
      'Switch it on when a customer needs it, like for an official receipt';

  @override
  String get taxCalled => 'Called';

  @override
  String get taxRate => 'Rate';

  @override
  String get taxYourPrices => 'Your prices';

  @override
  String get taxIncluded => 'Already include tax';

  @override
  String get taxOnTop => 'Tax added on top';

  @override
  String get currencySheetTitle => 'Currency';

  @override
  String get currencySheetSubtitle =>
      'Changes the symbol only. Amounts aren’t converted.';

  @override
  String get currencySomethingElse => 'Something else';

  @override
  String get currencySymbol => 'Symbol';

  @override
  String get currencySymbolHint => 'e.g. kr';

  @override
  String get currencyUse => 'Use';

  @override
  String get currencyNoCents => 'No cents';

  @override
  String get currencyNoCentsHint => 'Show 1,200 instead of 1,200.00';

  @override
  String pipSummary(String free, String promised) {
    return '$free free, $promised promised';
  }

  @override
  String pipSummaryReorder(String free, String promised, String level) {
    return '$free free, $promised promised, reorder at $level';
  }

  @override
  String get earningsTitle => 'Reports';

  @override
  String get earningsRangeWeek => 'Week';

  @override
  String get earningsRangeMonth => 'Month';

  @override
  String get earningsRangeYear => 'Year';

  @override
  String get earningsRangeCustom => 'Custom';

  @override
  String get earningsPickerHelp => 'Report on';

  @override
  String get earningsPickerShow => 'Show';

  @override
  String get earningsPrevious => 'Previous';

  @override
  String earningsOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '$count order',
    );
    return '$_temp0';
  }

  @override
  String earningsCustomers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count customers',
      one: '$count customer',
    );
    return '$_temp0';
  }

  @override
  String earningsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String earningsNetProfit(String orders) {
    return 'Net profit · $orders';
  }

  @override
  String get earningsNoOrders =>
      'No packed or shipped orders in this period. Profit counts once an order is packed.';

  @override
  String get earningsNoOrdersFiltered =>
      'No packed or shipped orders in this period match the filter.';

  @override
  String earningsMargin(String percent) {
    return '$percent% of sales is profit';
  }

  @override
  String earningsUnpaidLine(String amount, String orders) {
    return '$amount of it is still unpaid ($orders)';
  }

  @override
  String earningsByProduct(int count) {
    return 'By product · $count';
  }

  @override
  String earningsSoldSales(String sold, String sales) {
    return '$sold sold · $sales sales';
  }

  @override
  String get earningsWaste => 'Waste';

  @override
  String earningsWasteWithCost(String cost) {
    return 'Waste · $cost';
  }

  @override
  String get earningsNoWaste => 'No waste recorded in this period.';

  @override
  String earningsWasted(String quantity) {
    return '$quantity wasted';
  }

  @override
  String get earningsWaiting => 'Waiting for payment';

  @override
  String earningsWaitingSubtitle(String orders, String customers) {
    return '$orders · $customers';
  }

  @override
  String get earningsThisWeek => 'This week';

  @override
  String get earningsThisMonth => 'This month';

  @override
  String get earningsThisYear => 'This year';

  @override
  String get earningsLastWeek => 'Last week';

  @override
  String get earningsLastMonth => 'Last month';

  @override
  String get earningsProduct => 'Product';

  @override
  String get earningsProductEarnings => 'Product earnings';

  @override
  String get earningsProfitCaption => 'PROFIT';

  @override
  String get earningsStatSold => 'Sold';

  @override
  String get earningsStatSales => 'Sales';

  @override
  String get earningsStatPerItem => 'Per item';

  @override
  String earningsStatPerUnit(String unit) {
    return 'Per $unit';
  }

  @override
  String earningsOrdersHeader(int count) {
    return 'Orders · $count';
  }

  @override
  String get earningsNoProductOrders =>
      'No packed or shipped orders with this product in this period.';

  @override
  String get earningsProfitSplitNote =>
      'Each order’s profit is split across its products by share of sales.';

  @override
  String get earningsFilterTitle => 'Filter report';

  @override
  String get earningsFilterSubtitle =>
      'Only orders that match every choice are counted.';

  @override
  String get earningsFilterChannel => 'Channel';

  @override
  String get earningsFilterProducts => 'Has any of these products';

  @override
  String get earningsFilterStatus => 'Status';

  @override
  String get earningsFilterPayment => 'Payment';

  @override
  String get earningsFilterDiscount => 'Discount';

  @override
  String get earningsFilterTax => 'Tax';

  @override
  String get earningsFilterTotal => 'Order total';

  @override
  String get earningsFilterFrom => 'From';

  @override
  String get earningsFilterTo => 'To';

  @override
  String get earningsFilterClear => 'Clear all';

  @override
  String get earningsFilterShow => 'Show';

  @override
  String get earningsAny => 'Any';

  @override
  String get earningsPacked => 'Packed';

  @override
  String get earningsShipped => 'Shipped';

  @override
  String get earningsPaid => 'Paid';

  @override
  String get earningsUnpaid => 'Unpaid';

  @override
  String get earningsWithDiscount => 'With discount';

  @override
  String get earningsNoDiscount => 'No discount';

  @override
  String get earningsWithTax => 'With tax';

  @override
  String get earningsNoTax => 'No tax';

  @override
  String get earningsChipChannel => 'channel';

  @override
  String earningsChipChannels(int count) {
    return '$count channels';
  }

  @override
  String get earningsChipProduct => 'product';

  @override
  String earningsChipProducts(int count) {
    return '$count products';
  }

  @override
  String get earningsChipPackedOnly => 'Packed only';

  @override
  String get earningsChipShippedOnly => 'Shipped only';

  @override
  String get earningsChipPackedOrShipped => 'Packed or shipped';

  @override
  String earningsChipRange(String min, String max) {
    return '$min–$max';
  }

  @override
  String earningsChipAndUp(String min) {
    return '$min and up';
  }

  @override
  String earningsChipUpTo(String max) {
    return 'Up to $max';
  }

  @override
  String get notesEmptyTitle => 'No notes yet';

  @override
  String get notesEmptyMessage =>
      'Keep supplier details, product ideas and packing how-tos here.';

  @override
  String get notesAddNote => 'Add note';

  @override
  String get notesFab => 'Note';

  @override
  String get notesSearchHint => 'Search notes';

  @override
  String get notesNoMatches => 'No matches';

  @override
  String notesNoMatchesMessage(String query) {
    return 'No note mentions \"$query\".';
  }

  @override
  String notesPinnedHeader(int count) {
    return 'Pinned · $count';
  }

  @override
  String notesOthersHeader(int count) {
    return 'Others · $count';
  }

  @override
  String get notesUntitled => 'Untitled';

  @override
  String get notesPinToToday => 'Pin to Today';

  @override
  String get notesUnpin => 'Unpin';

  @override
  String get notesPin => 'Pin';

  @override
  String get notesPinnedLabel => 'Pinned';

  @override
  String get notesDeleteTitle => 'Delete note?';

  @override
  String notesDeleteMessage(String title) {
    return '$title is removed from your notebook.';
  }

  @override
  String notesChecklistDone(int done, int total) {
    return '$done/$total done';
  }

  @override
  String get notesOutcomePinned => 'Pinned to Today';

  @override
  String get notesOutcomeUnpinned => 'Unpinned';

  @override
  String notesOutcomeDeleted(String title) {
    return '$title deleted';
  }

  @override
  String notesOutcomeRestored(String title) {
    return '$title restored';
  }

  @override
  String get notesDiscardTitle => 'Discard changes?';

  @override
  String get notesDiscardNew => 'The note is not saved.';

  @override
  String get notesDiscardEdit => 'The note stays as it was.';

  @override
  String get notesDiscardConfirm => 'Discard';

  @override
  String get notesKeepEditing => 'Keep editing';

  @override
  String get notesNewNote => 'New note';

  @override
  String get notesEditNote => 'Edit note';

  @override
  String get notesMore => 'More';

  @override
  String get notesTitleHint => 'Title';

  @override
  String get notesBodyHint => 'Supplier details, ideas, how-tos…';

  @override
  String get orderFieldsTitle => 'Order fields';

  @override
  String get orderFieldsEmptyTitle => 'No order fields yet';

  @override
  String get orderFieldsEmptyMessage =>
      'Add what you note on every order: address, size, gift message…';

  @override
  String get orderFieldsAddField => 'Add field';

  @override
  String get orderFieldsFab => 'Field';

  @override
  String get orderFieldsDragReorder => 'Drag to reorder';

  @override
  String get orderFieldsArchivedHeader => 'Archived';

  @override
  String orderFieldsDeleteNamed(String name) {
    return 'Delete $name';
  }

  @override
  String get orderFieldsFooter =>
      'Fields are asked for in this order when you add an order. Archived fields stay on past orders but aren’t asked for on new ones.';

  @override
  String get orderFieldsEditField => 'Edit field';

  @override
  String orderFieldsArchiveTitle(String name) {
    return 'Archive $name?';
  }

  @override
  String orderFieldsDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String orderFieldsArchiveMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'the $count orders',
      one: 'the 1 order',
    );
    return 'It stays on $_temp0 that use it, but won’t be asked for on new ones.';
  }

  @override
  String get orderFieldsDeleteMessage =>
      'No order uses it, so it is removed for good.';

  @override
  String get orderFieldsNewField => 'New order field';

  @override
  String orderFieldsEditNamed(String name) {
    return 'Edit $name';
  }

  @override
  String get orderFieldsNameHint => 'e.g. Address';

  @override
  String get orderFieldsNameRequired => 'Enter a name';

  @override
  String get orderFieldsTypeLabel => 'Type';

  @override
  String get orderFieldsTypeText => 'Text';

  @override
  String get orderFieldsTypeNumber => 'Number';

  @override
  String get orderFieldsTypeDate => 'Date';

  @override
  String get orderFieldsTypeChoice => 'Choice';

  @override
  String get orderFieldsTypeLocked => 'Type can’t change once orders use it.';

  @override
  String get orderFieldsNumberNote =>
      'Numbers drop leading zeros. Use Text for phone numbers.';

  @override
  String get orderFieldsMultiline => 'Multi-line';

  @override
  String get orderFieldsMultilineHint => 'For longer text like an address';

  @override
  String get orderFieldsChoices => 'Choices';

  @override
  String orderFieldsChoiceHint(int number) {
    return 'Choice $number';
  }

  @override
  String get orderFieldsChoiceRequired => 'Add at least one choice';

  @override
  String get orderFieldsRemoveChoice => 'Remove choice';

  @override
  String get orderFieldsAddChoice => 'Add choice';

  @override
  String get orderFieldsChoicesKept =>
      'Orders keep the choice they were saved with, even if you rename or remove it here.';

  @override
  String get orderFieldsEnterNumber => 'Enter a number';

  @override
  String orderFieldsChoiceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count choices',
      one: '1 choice',
    );
    return '$_temp0';
  }

  @override
  String orderFieldsUsedOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
    );
    return 'used on $_temp0';
  }

  @override
  String get orderFieldsNotUsed => 'not used yet';

  @override
  String get orderFieldsFallbackName => 'Field';

  @override
  String orderFieldsOutcomeAdded(String name) {
    return '$name added';
  }

  @override
  String orderFieldsOutcomeSaved(String name) {
    return '$name saved';
  }

  @override
  String orderFieldsOutcomeArchived(String name) {
    return '$name archived';
  }

  @override
  String orderFieldsOutcomeDeleted(String name) {
    return '$name deleted';
  }

  @override
  String orderFieldsOutcomeRestored(String name) {
    return '$name restored';
  }

  @override
  String get socialTitle => 'Social shortcuts';

  @override
  String get socialEmptyTitle => 'No shortcuts yet';

  @override
  String get socialEmptyMessage =>
      'Keep your Facebook, TikTok, Shopee or Lazada page one tap away.';

  @override
  String get socialAddShortcut => 'Add shortcut';

  @override
  String get socialFab => 'Shortcut';

  @override
  String get socialOpen => 'Open';

  @override
  String get socialEditShortcut => 'Edit shortcut';

  @override
  String socialRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get socialRemoveMessage =>
      'Only the shortcut goes; the page itself is untouched.';

  @override
  String get socialHint =>
      'Tap a shortcut to open it in your browser or the app. Tap Edit to rearrange or change them.';

  @override
  String get socialNewShortcut => 'New shortcut';

  @override
  String socialEditNamed(String name) {
    return 'Edit $name';
  }

  @override
  String get socialSite => 'Site';

  @override
  String get socialOther => 'Other';

  @override
  String get socialNameHint => 'e.g. My website';

  @override
  String get socialNameRequired => 'Enter a name';

  @override
  String get socialLinkLabel => 'Link';

  @override
  String socialLinkInvalid(String example) {
    return 'Enter a web address like $example';
  }

  @override
  String get socialColour => 'Colour';

  @override
  String socialCouldntOpen(String name) {
    return 'Couldn’t open $name. Check the link.';
  }

  @override
  String socialOpenNamed(String name) {
    return 'Open $name';
  }

  @override
  String get socialDragReorder => 'Drag to reorder';

  @override
  String get socialFallbackName => 'Shortcut';

  @override
  String socialOutcomeAdded(String name) {
    return '$name added';
  }

  @override
  String socialOutcomeSaved(String name) {
    return '$name saved';
  }

  @override
  String socialOutcomeRemoved(String name) {
    return '$name removed';
  }

  @override
  String get updatesCheck => 'Check for updates';

  @override
  String get updatesCheckSubtitle => 'Get the newest version of Craftbook';

  @override
  String get updatesChecking => 'Checking…';

  @override
  String get updatesUpToDate => 'You’re on the newest version';

  @override
  String updatesUpdateTo(String version) {
    return 'Update to $version';
  }

  @override
  String get updatesTapToInstall => 'Tap to download and install';

  @override
  String get updatesDownloading => 'Downloading…';

  @override
  String updatesDownloadingPercent(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get updatesFailedFallback => 'Something went wrong. Tap to try again.';

  @override
  String get updatesDialogMessage =>
      'Your orders, stock and notes stay as they are.';

  @override
  String get updatesConfirm => 'Update';

  @override
  String get updatesLater => 'Later';

  @override
  String get ordersStatusToPack => 'To pack';

  @override
  String get ordersStatusPacked => 'Packed';

  @override
  String get ordersStatusShipped => 'Shipped';

  @override
  String get ordersStatusCancelled => 'Cancelled';

  @override
  String get ordersOverdue => 'Overdue';

  @override
  String get ordersPaymentAny => 'Any';

  @override
  String get ordersPaymentUnpaid => 'Unpaid';

  @override
  String get ordersPaymentPaid => 'Paid';

  @override
  String get ordersFilterTitle => 'Filter orders';

  @override
  String get ordersFilterSubtitle =>
      'Works together with the status chips and search.';

  @override
  String get ordersFilterPayment => 'Payment';

  @override
  String get ordersFilterClearAll => 'Clear all';

  @override
  String get ordersFilterShow => 'Show';

  @override
  String ordersItemCount(num count, String qty) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$qty items',
      one: '$qty item',
    );
    return '$_temp0';
  }

  @override
  String ordersOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
    );
    return '$_temp0';
  }

  @override
  String ordersLineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines',
      one: '1 line',
    );
    return '$_temp0';
  }

  @override
  String ordersMiniProfit(String amount) {
    return '$amount profit';
  }

  @override
  String get ordersUnpaidTag => 'Unpaid';

  @override
  String get ordersDateToday => 'Today';

  @override
  String get ordersDateTomorrow => 'Tomorrow';

  @override
  String get ordersDateYesterday => 'Yesterday';

  @override
  String get ordersWhenShipped => 'Shipped';

  @override
  String ordersWhenShippedOn(String date) {
    return 'Shipped $date';
  }

  @override
  String get ordersWhenCancelled => 'Cancelled';

  @override
  String get ordersWhenDueYesterday => 'Due yesterday';

  @override
  String ordersWhenDueDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Due $count days ago',
      one: 'Due 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get ordersWhenShipsToday => 'Ships today';

  @override
  String ordersWhenShips(String date) {
    return 'Ships $date';
  }

  @override
  String ordersActionTitle(String id, String customer) {
    return 'Order #$id · $customer';
  }

  @override
  String get ordersMarkShipped => 'Mark shipped';

  @override
  String get ordersMarkPaid => 'Mark paid';

  @override
  String get ordersMarkUnpaid => 'Mark unpaid';

  @override
  String get ordersEditNote => 'Edit note';

  @override
  String get ordersEditOrder => 'Edit order';

  @override
  String get ordersCancelOrder => 'Cancel order';

  @override
  String get ordersRestoreOrder => 'Restore order';

  @override
  String get ordersDeleteOrder => 'Delete order';

  @override
  String get ordersToastShipped => 'Marked as shipped';

  @override
  String get ordersToastPaid => 'Marked as paid';

  @override
  String get ordersToastUnpaid => 'Marked as unpaid';

  @override
  String get ordersToastCancelled => 'Order cancelled. Stock returned.';

  @override
  String get ordersToastRestored => 'Order restored';

  @override
  String get ordersToastDeleted => 'Order deleted';

  @override
  String get ordersToastPacked => 'Packed. Stock updated.';

  @override
  String get ordersToastMaterialsUpdated => 'Materials updated';

  @override
  String ordersCancelTitle(String id) {
    return 'Cancel order #$id?';
  }

  @override
  String get ordersCancelMessageShipped =>
      'Use this when it came back or never went out. Its materials go back on the shelf, and the order stays in your list as cancelled, out of your reports. You can delete it after.';

  @override
  String get ordersCancelMessagePacked =>
      'Its materials go back on the shelf. The order stays in your list as cancelled and doesn’t count toward earnings.';

  @override
  String get ordersCancelMessagePending =>
      'Its reserved stock is released. The order stays in your list as cancelled and doesn’t count toward earnings.';

  @override
  String get ordersCancelConfirm => 'Cancel order';

  @override
  String get ordersCancelKeep => 'Keep order';

  @override
  String ordersRestoreTitle(String id) {
    return 'Restore order #$id?';
  }

  @override
  String get ordersRestoreMessage =>
      'It goes back to To pack and reserves its materials again.';

  @override
  String ordersDeleteTitle(String id) {
    return 'Delete order #$id?';
  }

  @override
  String get ordersDeleteMessagePacked =>
      'The order is removed and its materials go back on the shelf.';

  @override
  String get ordersDeleteMessageCancelled =>
      'The cancelled order is removed for good.';

  @override
  String get ordersDeleteMessagePending =>
      'The order is removed and its reserved stock is released.';

  @override
  String get ordersNoteOptional => 'Note (optional)';

  @override
  String get ordersNotePlaceholder =>
      'Gift wrap, colour requests, packing steps…';

  @override
  String get ordersNoteAdd => 'Add note';

  @override
  String get ordersDiscardChangesTitle => 'Discard changes?';

  @override
  String get ordersNoteStaysMessage => 'The note stays as it was.';

  @override
  String get ordersDiscard => 'Discard';

  @override
  String get ordersKeepEditing => 'Keep editing';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersNewOrder => 'New order';

  @override
  String get ordersSearchHint => 'Search name, # or channel';

  @override
  String get ordersGroupPacked => 'Packed, ready to ship';

  @override
  String get ordersGroupDueThisWeek => 'Due this week';

  @override
  String get ordersGroupLater => 'Later';

  @override
  String get ordersEmptyNoneTitle => 'No orders yet';

  @override
  String get ordersEmptyNoneMessage => 'Your first order will show up here.';

  @override
  String get ordersNoMatches => 'No matches';

  @override
  String ordersNoMatchesFor(String query) {
    return 'Nothing matches “$query”.';
  }

  @override
  String get ordersNothingWaiting => 'Nothing waiting for payment';

  @override
  String get ordersNoPaidHere => 'No paid orders here';

  @override
  String get ordersNothingToPack => 'Nothing to pack';

  @override
  String get ordersAllPackedMessage => 'Every order is packed. Nice work.';

  @override
  String ordersNoStatusOrders(String status) {
    return 'No $status orders';
  }

  @override
  String get ordersReceivablesTitle => 'Waiting for payment';

  @override
  String get ordersReceivablesEmptyTitle => 'Everyone has paid';

  @override
  String get ordersReceivablesEmptyMessage =>
      'Orders marked unpaid will show up here.';

  @override
  String ordersReceivablesOwed(String orders) {
    return 'Owed to you · $orders';
  }

  @override
  String get ordersReceivablesHint =>
      'Mark an order paid from its page or by long-pressing it.';

  @override
  String ordersDetailHeader(String id) {
    return 'ORDER #$id';
  }

  @override
  String get ordersMenuMore => 'More';

  @override
  String get ordersItemsCaps => 'ITEMS';

  @override
  String get ordersPlaced => 'Placed';

  @override
  String ordersPlacedOn(String date) {
    return 'Placed $date';
  }

  @override
  String ordersDueOn(String date) {
    return 'due $date';
  }

  @override
  String get ordersCustomer => 'Customer';

  @override
  String ordersFieldCopied(String label) {
    return '$label copied';
  }

  @override
  String get ordersDiscountsLine => 'Discounts';

  @override
  String get ordersItemsLine => 'Items';

  @override
  String ordersIncludesTax(String amount, String tax, String rate) {
    return 'Includes $amount $tax ($rate%)';
  }

  @override
  String ordersPaidOn(String date) {
    return 'Paid $date';
  }

  @override
  String get ordersPaid => 'Paid';

  @override
  String get ordersWaitingForPayment => 'Waiting for payment';

  @override
  String get ordersTotalCaps => 'ORDER TOTAL';

  @override
  String get ordersAdjust => 'Adjust';

  @override
  String get ordersPackOrder => 'Pack order';

  @override
  String get ordersMaterials => 'Materials';

  @override
  String ordersMaterialsLines(String lines) {
    return 'Materials · $lines';
  }

  @override
  String ordersMaterialsLinesWaste(String lines) {
    return 'Materials · $lines · waste';
  }

  @override
  String get ordersChannelFees => 'Channel fees';

  @override
  String ordersChannelFeesNamed(String channel) {
    return '$channel fees';
  }

  @override
  String ordersPlannedUsed(String planned, String used) {
    return 'Planned $planned · used $used';
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
    return '$qty × $price · from stock';
  }

  @override
  String get ordersWasteCutting => 'Cutting';

  @override
  String get ordersWasteDefect => 'Defect';

  @override
  String get ordersWasteMiscount => 'Miscount';

  @override
  String get ordersWasteOther => 'Other';

  @override
  String get ordersAdjustTitle => 'Materials used';

  @override
  String get ordersAdjustIntro =>
      'Record what you actually used. Anything over plan counts as waste and comes out of this order’s profit.';

  @override
  String ordersPlannedPerUnit(String qty, String price, String unit) {
    return 'Planned $qty · $price/$unit';
  }

  @override
  String ordersPlannedEach(String qty, String price) {
    return 'Planned $qty · $price each';
  }

  @override
  String ordersWasteCost(String qty, String cost) {
    return '+$qty waste · $cost';
  }

  @override
  String get ordersWhy => 'Why?';

  @override
  String ordersFewerThanPlanned(String qty) {
    return '$qty fewer than planned';
  }

  @override
  String get ordersPackTitle => 'Pack this order?';

  @override
  String get ordersPackNothing => 'Nothing to take from stock for this order.';

  @override
  String get ordersPackIntro => 'These pieces come off your shelf.';

  @override
  String ordersPackShort(String names) {
    return 'Short on $names.';
  }

  @override
  String get ordersPackShortMessage => 'Stock will stop at 0.';

  @override
  String get ordersPackConfirm => 'Pack & deduct';

  @override
  String get ordersAddProduct => 'Add product';

  @override
  String get ordersSearchProducts => 'Search products';

  @override
  String get ordersNoProducts => 'No products yet';

  @override
  String get ordersNoProductsMessage =>
      'Add products under More → Products first.';

  @override
  String get ordersOutOfStock => 'Out of stock';

  @override
  String get ordersCantBuild => 'Can’t build: not enough materials';

  @override
  String ordersInStock(String qty) {
    return 'In stock $qty';
  }

  @override
  String ordersCanBuild(String qty) {
    return 'Can build $qty';
  }

  @override
  String get ordersAddedTag => 'Added';

  @override
  String get ordersDiscountsCaps => 'DISCOUNTS';

  @override
  String get ordersManage => 'Manage';

  @override
  String ordersRemoveDiscount(String label) {
    return 'Remove $label';
  }

  @override
  String get ordersAddDiscountChip => '+ Add discount';

  @override
  String get ordersOtherDiscountChip => '+ Other';

  @override
  String get ordersAddDiscountTitle => 'Add a discount';

  @override
  String ordersTaxInPrices(String tax, String rate) {
    return '$tax $rate% · in prices';
  }

  @override
  String ordersTaxOnTop(String tax, String rate) {
    return '$tax $rate% · added on top';
  }

  @override
  String get ordersTaxOff => 'Off for this order';

  @override
  String ordersTaxPartOfTotal(String amount, String tax) {
    return '$amount of the total is $tax';
  }

  @override
  String ordersTaxCustomerPays(String amount) {
    return 'Customer pays $amount more';
  }

  @override
  String get ordersPaidSwitch => 'Paid';

  @override
  String get ordersPaidHasPaid => 'The customer has paid';

  @override
  String ordersPaidWaitingFor(String amount) {
    return 'Waiting for $amount';
  }

  @override
  String get ordersPickChannel => 'Pick a sales channel';

  @override
  String get ordersDiscardEditTitle => 'Discard your changes?';

  @override
  String get ordersDiscardNewTitle => 'Discard this order?';

  @override
  String get ordersDiscardEditMessage => 'The order stays as it was.';

  @override
  String get ordersDiscardNewMessage =>
      'What you’ve entered so far will be lost.';

  @override
  String ordersSaved(String id) {
    return 'Order #$id saved';
  }

  @override
  String ordersUpdated(String id) {
    return 'Order #$id updated';
  }

  @override
  String get ordersEditTitle => 'Edit order';

  @override
  String ordersEditTitleId(String id) {
    return 'Edit order #$id';
  }

  @override
  String get ordersStepDetails => 'Details';

  @override
  String get ordersStepCustomer => 'Customer';

  @override
  String get ordersStepItems => 'Items';

  @override
  String get ordersStepReview => 'Review';

  @override
  String get ordersCustomerName => 'Customer name';

  @override
  String get ordersEnterCustomerName => 'Enter the customer name';

  @override
  String get ordersAddOrderFields => 'Add order fields (address, size…)';

  @override
  String get ordersChannel => 'Channel';

  @override
  String get ordersNoChannelsTitle => 'No sales channels yet.';

  @override
  String get ordersNoChannelsMessage => 'Add one to work out fees.';

  @override
  String get ordersOrderDate => 'Order date';

  @override
  String get ordersShipBy => 'Ship by';

  @override
  String get ordersNoItemsTitle => 'No items yet';

  @override
  String get ordersNoItemsMessage => 'Add the products this customer ordered.';

  @override
  String ordersEachSubtotal(String price, String subtotal) {
    return '$price each · $subtotal';
  }

  @override
  String get ordersRemoveHint => 'Set a quantity to 0 to remove it.';

  @override
  String ordersShipsByItems(String date, String items) {
    return 'Ships by $date · $items';
  }

  @override
  String get ordersShortBannerTitle => 'Not enough stock for some pieces.';

  @override
  String get ordersShortBannerMessage =>
      'You can still save; the buy list will show what to get.';

  @override
  String get ordersSaving => 'Saving…';

  @override
  String get ordersSaveChanges => 'Save changes';

  @override
  String get ordersSaveOrder => 'Save order';

  @override
  String get ordersNextAddItems => 'Next: add items';

  @override
  String get ordersReview => 'Review';

  @override
  String get ordersTotal => 'Total';

  @override
  String get ordersReservesCaps => 'RESERVES FROM STOCK';

  @override
  String ordersOnlyFree(String qty, String free) {
    return '$qty · only $free free';
  }

  @override
  String ordersLastOne(num count, String qty) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$qty · last ones',
      one: '$qty · last one',
    );
    return '$_temp0';
  }

  @override
  String get todayToPackToday => 'To pack today';

  @override
  String get todayNewToday => 'New today';

  @override
  String get todayWeekProfit => 'Week profit';

  @override
  String get todayCalendar => 'Calendar';

  @override
  String todayLowStock(int count) {
    return '$count low:';
  }

  @override
  String get todayBuyList => 'Buy list';

  @override
  String todayPinnedNotes(int count) {
    return 'Pinned notes · $count';
  }

  @override
  String get todayAllNotes => 'All notes';

  @override
  String todayShipsToday(int count) {
    return 'Ships today · $count';
  }

  @override
  String todayNewTodaySection(int count) {
    return 'New today · $count';
  }

  @override
  String get todayAllClear => 'All clear for today';

  @override
  String get todayAllClearMessage =>
      'Orders shipping today and new orders show up here.';

  @override
  String get todayNoFilterMatch => 'Nothing matches this filter';

  @override
  String get todayPickAnotherStatus => 'Pick another status or tap All.';

  @override
  String todayNoteDeleted(String title) {
    return '$title deleted';
  }

  @override
  String get todayPrevWeek => 'Previous week';

  @override
  String get todayNextWeek => 'Next week';

  @override
  String get todayPrevMonth => 'Previous month';

  @override
  String get todayNextMonth => 'Next month';

  @override
  String get todayWeek => 'Week';

  @override
  String get todayMonth => 'Month';

  @override
  String get todayNothingDue => 'Nothing due';

  @override
  String get todayNothingShipsDay => 'Nothing ships this day.';

  @override
  String todayDayOrders(String date, String orders) {
    return '$date · $orders';
  }

  @override
  String get productsInventoryTitle => 'Inventory';

  @override
  String get productsTabProducts => 'Products';

  @override
  String get productsTabMaterials => 'Materials';

  @override
  String get productsFabProduct => 'Product';

  @override
  String get productsFabMaterial => 'Material';

  @override
  String get productsTypeAny => 'Any';

  @override
  String get productsTypeHandmade => 'Handmade';

  @override
  String get productsTypeResell => 'Resell';

  @override
  String get productsStockAny => 'Any';

  @override
  String get productsStockLow => 'Low';

  @override
  String get productsStockShort => 'Short';

  @override
  String get productsStockArchived => 'Archived';

  @override
  String get productsFilterTitle => 'Filter products';

  @override
  String get productsFilterSubtitle => 'Works together with search.';

  @override
  String get productsFilterType => 'Type';

  @override
  String get productsFilterStock => 'Stock';

  @override
  String get productsFilterClearAll => 'Clear all';

  @override
  String get productsFilterShow => 'Show';

  @override
  String get productsSearchHint => 'Search products';

  @override
  String get productsEmptyTitle => 'No products yet';

  @override
  String get productsEmptyMessage =>
      'Add what you sell and the materials it is made from.';

  @override
  String get productsAddProduct => 'Add product';

  @override
  String get productsNoMatches => 'No matches';

  @override
  String productsNoMatchesFor(String query) {
    return 'Nothing matches \"$query\".';
  }

  @override
  String get productsNoFilterMatchTitle => 'Nothing matches these filters';

  @override
  String get productsNoFilterMatchMessage => 'Tap a filter above to remove it.';

  @override
  String get productsNoHandmadeTitle => 'No handmade products';

  @override
  String get productsNoHandmadeMessage =>
      'Products made from your materials show up here.';

  @override
  String get productsNoResellTitle => 'No resell products';

  @override
  String get productsNoResellMessage =>
      'Things you buy ready-made and sell on show up here.';

  @override
  String get productsAllArchivedTitle => 'Every product is archived';

  @override
  String get productsAllArchivedMessage => 'Filter by Archived to see them.';

  @override
  String get productsNothingLowTitle => 'Nothing is low';

  @override
  String get productsNothingLowMessage =>
      'Set a warning level on a product to watch it here.';

  @override
  String get productsActionEdit => 'Edit product';

  @override
  String get productsActionReceive => 'Receive stock';

  @override
  String get productsActionDelete => 'Delete product';

  @override
  String productsArchivedSnack(String name) {
    return '$name archived';
  }

  @override
  String productsUnarchivedSnack(String name) {
    return '$name is back in your lists';
  }

  @override
  String productsDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get productsDeleteMessage =>
      'This can’t be undone. Products that appear in orders can’t be deleted; archive them instead.';

  @override
  String get productsDeletedSnack => 'Product deleted';

  @override
  String get productsTagResell => 'Resell';

  @override
  String get productsTagArchived => 'Archived';

  @override
  String get productsTagShortForOrders => 'Short for orders';

  @override
  String productsCardCost(String cost) {
    return 'Cost $cost';
  }

  @override
  String productsCardMargin(String percent) {
    return '$percent% margin';
  }

  @override
  String get productsInStock => 'In stock';

  @override
  String get productsCanBuild => 'Can build';

  @override
  String productsPhotoOf(String name) {
    return 'Photo of $name';
  }

  @override
  String get productsOnHandCaps => 'ON HAND';

  @override
  String productsUnitOnHandCaps(String unit) {
    return '$unit ON HAND';
  }

  @override
  String get productsCanBuildCaps => 'CAN BUILD';

  @override
  String get productsStatShort => 'Short';

  @override
  String get productsStatFree => 'Free';

  @override
  String get productsStatPromised => 'Promised';

  @override
  String get productsStatReorderAt => 'Reorder at';

  @override
  String get productsStatWarnAt => 'Warn at';

  @override
  String get productsStatSellPrice => 'Sell price';

  @override
  String get productsStatCost => 'Cost';

  @override
  String get productsStatMargin => 'Margin';

  @override
  String get productsProfitPerItem => 'PROFIT PER ITEM';

  @override
  String productsProfitPerUnit(String unit) {
    return 'PROFIT PER $unit';
  }

  @override
  String productsProfitNote(String cost, String kind, String margin) {
    String _temp0 = intl.Intl.selectLogic(
      kind,
      {
        'resell': 'cost',
        'other': 'materials',
      },
    );
    return '$cost $_temp0 · $margin% margin · before channel fees';
  }

  @override
  String get productsPhotoTitle => 'Product photo';

  @override
  String get productsPhotoSubtitle =>
      'Shown when you pick products for an order.';

  @override
  String get productsPhotoTake => 'Take photo';

  @override
  String get productsPhotoGallery => 'Choose from gallery';

  @override
  String get productsPhotoRemove => 'Remove photo';

  @override
  String get productsPhotoCameraFailed => 'Couldn’t open the camera';

  @override
  String get productsPhotoGalleryFailed => 'Couldn’t open your photos';

  @override
  String get productsPhotoAdd => 'Add photo';

  @override
  String get productsPhotoChange => 'Change photo';

  @override
  String get productsPhotoHelp =>
      'Helps you spot the right item when making an order.';

  @override
  String get productsHistInitial => 'Initial stock';

  @override
  String get productsHistReturned => 'Returned from deleted order';

  @override
  String get productsHistReceived => 'Received';

  @override
  String get productsHistUsed => 'Used in an order';

  @override
  String get productsHistCounted => 'Counted';

  @override
  String get productsNotFound => 'Product not found';

  @override
  String get productsCountTitle => 'Count stock';

  @override
  String get productsCountSubtitle => 'Set how many are actually on the shelf.';

  @override
  String get productsCountSave => 'Save count';

  @override
  String productsStockSet(String qty) {
    return 'Stock set to $qty';
  }

  @override
  String get productsReceive => 'Receive';

  @override
  String get productsCount => 'Count';

  @override
  String productsMaterialsPerItem(String count) {
    return 'Materials per item · $count';
  }

  @override
  String productsMaterialsPerUnit(String unit, String count) {
    return 'Materials per $unit · $count';
  }

  @override
  String get productsNoMaterialsYet =>
      'No materials yet. Edit the product to add them.';

  @override
  String productsMakesCount(String makes) {
    return 'makes $makes';
  }

  @override
  String get productsHistoryTitle => 'History';

  @override
  String productsHistoryError(String error) {
    return 'Couldn’t load history: $error';
  }

  @override
  String get productsHistoryEmpty => 'No sales or stock changes yet.';

  @override
  String get productsReceiveCaps => 'RECEIVE';

  @override
  String get productsQuantityReceivedCaps => 'QUANTITY RECEIVED';

  @override
  String get productsPriceEach => 'Price each';

  @override
  String productsPricePerUnit(String unit) {
    return 'Price per $unit';
  }

  @override
  String get productsAfterReceivingCaps => 'AFTER RECEIVING';

  @override
  String get productsUnitCostWeighted => 'Unit cost (weighted)';

  @override
  String productsReceivedSnack(String qty, String name) {
    return 'Added $qty to $name';
  }

  @override
  String productsReceiveButton(String qty) {
    return 'Add $qty to stock';
  }

  @override
  String get productsNewProduct => 'New product';

  @override
  String get productsEditProduct => 'Edit product';

  @override
  String get productsEnterName => 'Enter a name';

  @override
  String get productsDescriptionOptional => 'Description (optional)';

  @override
  String get productsPriceAboveZero => 'Enter a price above 0';

  @override
  String get productsSoldCountedIn => 'Sold and counted in';

  @override
  String get productsLockOrders => 'Used in orders, so its type is fixed.';

  @override
  String get productsLockStock =>
      'It has stock on hand or reserved, so its type is fixed.';

  @override
  String get productsLockBom =>
      'Remove its materials first to switch it to Resell.';

  @override
  String get productsTypeHintResell =>
      'Bought ready-made. Tracks its own stock.';

  @override
  String get productsTypeHintHandmade =>
      'Made from materials. Stock comes from what you can build.';

  @override
  String get productsSaving => 'Saving…';

  @override
  String get productsSaveChanges => 'Save changes';

  @override
  String productsAddedSnack(String name) {
    return '$name added';
  }

  @override
  String get productsChangesSaved => 'Changes saved';

  @override
  String productsMakesAboveZero(String material) {
    return '$material: Makes must be above 0';
  }

  @override
  String get productsCostPerItem => 'Cost per item';

  @override
  String productsCostPerUnit(String unit) {
    return 'Cost per $unit';
  }

  @override
  String get productsMaterialsPerItemLabel => 'Materials per item';

  @override
  String productsMaterialsPerUnitLabel(String unit) {
    return 'Materials per $unit';
  }

  @override
  String get productsAddMaterialTitle => 'Add material';

  @override
  String get productsNoMaterialsTitle => 'No materials yet';

  @override
  String get productsAllMaterialsAdded => 'All materials added';

  @override
  String get productsAddMaterialsFirst => 'Add materials under Stock first.';

  @override
  String get productsSearchMaterials => 'Search materials';

  @override
  String get productsAddMaterialsHint =>
      'Add what this is made from so the app can work out its cost and reserve stock.';

  @override
  String productsCostEach(String cost) {
    return '$cost each';
  }

  @override
  String get productsUses => 'Uses';

  @override
  String get productsMakes => 'Makes';

  @override
  String get productsBomHelp =>
      'Uses is how much of the material goes in, Makes is how many of this product that makes (1 sheet makes 9 cards). Set Uses to 0 to remove a material.';

  @override
  String get productsReorderAtOptional => 'Reorder at (optional)';

  @override
  String get productsWarnWhenCanMake => 'Warn when I can make (optional)';

  @override
  String get productsReorderHelp => 'Warn when stock drops to this.';

  @override
  String get productsWarnHelp => 'Warn when materials only cover this many.';

  @override
  String get productsStockSection => 'Stock';

  @override
  String get productsCostRecalc =>
      'Receiving stock recalculates this as an average.';

  @override
  String get productsOnHandNow => 'On hand now';

  @override
  String get productsChannelsTitle => 'Channels & fees';

  @override
  String get productsChannelAdded => 'Channel added';

  @override
  String get productsChannelDeleted => 'Channel deleted';

  @override
  String get productsChannelsEmptyTitle => 'No channels yet';

  @override
  String get productsChannelsEmptyMessage =>
      'Add Shopee, TikTok Shop, walk-in… with their fees so profit is accurate.';

  @override
  String get productsChannelAddButton => 'Add channel';

  @override
  String productsChannelsNote(String sale) {
    return 'Examples use a $sale sale. Turned-off channels stay on past orders but are hidden when you create new ones.';
  }

  @override
  String get productsChannelFab => 'Channel';

  @override
  String get productsChannelEdit => 'Edit channel';

  @override
  String get productsChannelDelete => 'Delete channel';

  @override
  String get productsChannelTurnOff => 'Turn off';

  @override
  String get productsChannelTurnOn => 'Turn on';

  @override
  String productsChannelDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get productsChannelDeleteMessage =>
      'Channels used by orders can’t be deleted. Turn them off instead.';

  @override
  String get productsChannelNew => 'New channel';

  @override
  String productsChannelEditTitle(String name) {
    return 'Edit $name';
  }

  @override
  String get productsChannelNameHint => 'e.g. Shopee';

  @override
  String get productsChannelCommission => 'Commission';

  @override
  String get productsChannelTransactionFee => 'Transaction fee';

  @override
  String get productsChannelFixedFee => 'Fixed fee';

  @override
  String get productsChannelShippingYouPay => 'Shipping you pay';

  @override
  String get productsChannelPaidWhenPlaced => 'Orders are paid when placed';

  @override
  String get productsChannelPaidUpfront =>
      'Like a marketplace that collects up front';

  @override
  String get productsChannelUnpaidStart =>
      'New orders start unpaid, for cash on delivery or chat sales';

  @override
  String productsChannelYouKeep(String sale) {
    return 'On a $sale sale you keep';
  }

  @override
  String get productsChannelBeforeMaterials => 'before materials.';

  @override
  String get productsChannelNoFees => 'No fees';

  @override
  String productsChannelRecipeShipping(String fees, String shipping) {
    return '$fees · you pay $shipping shipping';
  }

  @override
  String productsChannelHiddenKeep(String sale) {
    return 'Hidden from new orders · on a $sale sale you keep';
  }

  @override
  String get unitsTitle => 'Units of measure';

  @override
  String get unitsEmptyTitle => 'No units yet';

  @override
  String get unitsEmptyMessage =>
      'Add what you count things in, like pc, sheet or kg.';

  @override
  String get unitsAddButton => 'Add unit';

  @override
  String get unitsFab => 'Unit';

  @override
  String get unitsNew => 'New unit';

  @override
  String unitsEditTitle(String label) {
    return 'Edit $label';
  }

  @override
  String get unitsDefaultNote => 'New items start on this';

  @override
  String get unitsActionEdit => 'Edit unit';

  @override
  String get unitsActionUseForNew => 'Use for new items';

  @override
  String unitsDeleteTitle(String label) {
    return 'Delete $label?';
  }

  @override
  String get unitsDeleteMessage =>
      'Materials and products counted in it keep their numbers, so move them to another unit first.';

  @override
  String get unitsDefaultTag => 'Default';

  @override
  String get unitsDragToReorder => 'Drag to reorder';

  @override
  String get unitsFooter =>
      'Everything you count is written with one of these: stock, what a product uses, what an order reserves. Long-press one to rename it, make it the default for new items, or delete it.';

  @override
  String get unitsPickerSubtitle => 'Every number for this is written with it.';

  @override
  String get unitsPickerHelper => 'Add more in More → Units of measure';

  @override
  String get unitsFieldLabel => 'Unit';

  @override
  String get unitsFieldHint => 'e.g. sheet, board, kg';

  @override
  String get unitsFieldHelper =>
      'Shown exactly as you type it, so an abbreviation like kg or m stays correct.';

  @override
  String get unitsNameRequired => 'Give the unit a name';

  @override
  String unitsTooLong(String max) {
    return 'Keep it under $max characters — it shows next to every number';
  }

  @override
  String get discountsTitle => 'Discounts';

  @override
  String get discountsEmptyTitle => 'No discounts yet';

  @override
  String get discountsEmptyMessage =>
      'Save the ones you give often, like 10% for regulars. You can still type any discount on an order.';

  @override
  String get discountsAddButton => 'Add discount';

  @override
  String get discountsFab => 'Discount';

  @override
  String get discountsNew => 'New discount';

  @override
  String discountsEditTitle(String label) {
    return 'Edit $label';
  }

  @override
  String get discountsActionEdit => 'Edit discount';

  @override
  String discountsDeleteTitle(String label) {
    return 'Delete $label?';
  }

  @override
  String get discountsDeleteMessage => 'Orders that already have it keep it.';

  @override
  String get discountsDragToReorder => 'Drag to reorder';

  @override
  String get discountsFooter =>
      'These show as one-tap chips when you review an order. Orders keep their own copy, so editing one here never changes past orders.';

  @override
  String get discountsNameHint => 'e.g. Loyal customer';

  @override
  String get discountsKindPercent => 'Percent';

  @override
  String get discountsKindFixed => 'Fixed amount';

  @override
  String get discountsPercentOff => 'Percent off';

  @override
  String get discountsAmountOff => 'Amount off';

  @override
  String get discountsPercentHelper => 'Taken off the items total';

  @override
  String get discountsFixedHelper => 'Taken off the order once';

  @override
  String get discountsNameRequired => 'Give the discount a name';

  @override
  String get discountsAmountRequired => 'Enter an amount above zero';

  @override
  String get discountsPercentMax => 'A percentage can be at most 100';

  @override
  String get stockActionReceive => 'Receive stock';

  @override
  String get stockActionEdit => 'Edit material';

  @override
  String get stockActionDelete => 'Delete material';

  @override
  String stockArchivedSnack(String name) {
    return '$name archived';
  }

  @override
  String stockUnarchivedSnack(String name) {
    return '$name is back in your lists';
  }

  @override
  String stockDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get stockDeleteBody =>
      'This can’t be undone. Materials used in a product or an order can’t be deleted; archive them instead.';

  @override
  String stockDeleteOnHand(String quantity) {
    return 'You still have $quantity on hand. Its stock history goes too.';
  }

  @override
  String stockDeletedSnack(String name) {
    return '$name deleted';
  }

  @override
  String get stockFilterAny => 'Any';

  @override
  String get stockFilterLow => 'Low';

  @override
  String get stockFilterPromised => 'Promised';

  @override
  String get stockFilterArchived => 'Archived';

  @override
  String get stockFilterTitle => 'Filter materials';

  @override
  String get stockFilterSubtitle => 'Works together with search.';

  @override
  String get stockFilterStock => 'Stock';

  @override
  String get stockFilterClear => 'Clear all';

  @override
  String get stockFilterShow => 'Show';

  @override
  String get stockArchivedTag => 'Archived';

  @override
  String stockCardFree(String quantity) {
    return '$quantity free';
  }

  @override
  String stockCardPromised(String quantity) {
    return '$quantity promised';
  }

  @override
  String stockCardReorderAt(String quantity) {
    return 'reorder at $quantity';
  }

  @override
  String stockCardShort(String quantity) {
    return '$quantity short';
  }

  @override
  String get stockBuyListButton => 'Buy list';

  @override
  String stockBuyListButtonCount(int count) {
    return 'Buy list · $count';
  }

  @override
  String get stockSearchHint => 'Search materials';

  @override
  String get stockEmptyNoneTitle => 'No materials yet';

  @override
  String get stockEmptyNoneMessage =>
      'Add the beads, yarn and boxes your products are made from.';

  @override
  String get stockAddMaterial => 'Add material';

  @override
  String get stockEmptyNoMatchTitle => 'No matches';

  @override
  String stockEmptyNoMatchMessage(String query) {
    return 'Nothing matches \"$query\".';
  }

  @override
  String get stockEmptyAllArchivedTitle => 'Every material is archived';

  @override
  String get stockEmptyAllArchivedMessage => 'Filter by Archived to see them.';

  @override
  String get stockEmptyNotLowTitle => 'Nothing is low';

  @override
  String get stockEmptyNotLowMessage =>
      'Every material is above its reorder level.';

  @override
  String get stockEmptyNoPromisedTitle => 'Nothing promised';

  @override
  String get stockEmptyNoPromisedMessage =>
      'Materials reserved by open orders show up here.';

  @override
  String get stockMaterialNotFound => 'Material not found';

  @override
  String get stockReceiveCaption => 'RECEIVE';

  @override
  String get stockReceiveEnterPrice => 'Enter what you paid per pack';

  @override
  String stockReceiveAdded(String quantity, String name) {
    return 'Added $quantity of $name';
  }

  @override
  String get stockReceivePacksCaption => 'PACKS RECEIVED';

  @override
  String stockReceivePerPack(String quantity) {
    return '$quantity per pack';
  }

  @override
  String get stockReceivePriceLabel => 'Price per pack';

  @override
  String get stockSupplierOptional => 'Supplier (optional)';

  @override
  String get stockReceiveAfterCaption => 'AFTER RECEIVING';

  @override
  String get stockReceiveUnitCost => 'Unit cost (weighted)';

  @override
  String get stockReceiveCostUp =>
      'Products using this will cost a bit more to make.';

  @override
  String stockReceiveAddButton(String quantity) {
    return 'Add $quantity to stock';
  }

  @override
  String stockPacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs',
      one: '$count pack',
    );
    return '$_temp0';
  }

  @override
  String get stockBuyListTitle => 'Buy list';

  @override
  String get stockBuyListCopyHeader => 'CraftBook buy list';

  @override
  String stockBuyListCopyLine(String name, String amount, String cost) {
    return '- $name: $amount, $cost';
  }

  @override
  String stockBuyListCopyTotal(String total) {
    return 'Total: $total';
  }

  @override
  String get stockBuyListCopied => 'Buy list copied';

  @override
  String get stockBuyEmptyTitle => 'Nothing to buy';

  @override
  String get stockBuyEmptyMessage => 'Everything is above its reorder level.';

  @override
  String stockBuyItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$_temp0';
  }

  @override
  String get stockBuyCopyList => 'Copy list';

  @override
  String get stockBuyTagResell => 'Resell';

  @override
  String stockBuyTagBlocking(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Blocking $count orders',
      one: 'Blocking $count order',
    );
    return '$_temp0';
  }

  @override
  String get stockBuyTagOutOfFree => 'Out of free stock';

  @override
  String get stockBuyTagBelowReorder => 'Below reorder';

  @override
  String get stockBuyVerb => 'Buy';

  @override
  String stockBuyFreeNow(String quantity) {
    return '$quantity free now';
  }

  @override
  String stockBuyHoldsUp(String products) {
    return 'Holds up: $products';
  }

  @override
  String get stockCountTitle => 'Count stock';

  @override
  String get stockCountSubtitle => 'Set the real amount on the shelf.';

  @override
  String stockCountMatches(String quantity) {
    return 'Matches the app ($quantity)';
  }

  @override
  String stockCountDiff(String change, String quantity) {
    return '$change from $quantity in the app';
  }

  @override
  String get stockCountSave => 'Save count';

  @override
  String stockCountSet(String quantity) {
    return 'Stock set to $quantity';
  }

  @override
  String get stockOnHandCaption => 'ON HAND';

  @override
  String stockUnitOnHandCaption(String unit) {
    return '$unit ON HAND';
  }

  @override
  String get stockStatShort => 'Short';

  @override
  String get stockStatFree => 'Free';

  @override
  String get stockStatPromised => 'Promised';

  @override
  String get stockStatReorderAt => 'Reorder at';

  @override
  String get stockStatUnitCost => 'Unit cost';

  @override
  String get stockStatPack => 'Pack';

  @override
  String get stockStatSupplier => 'Supplier';

  @override
  String get stockReceive => 'Receive';

  @override
  String get stockCount => 'Count';

  @override
  String stockUsedIn(int count) {
    return 'Used in · $count';
  }

  @override
  String get stockUsedInEmpty => 'Not part of any product yet.';

  @override
  String get stockHistory => 'History';

  @override
  String get stockHistoryEmpty => 'No stock changes yet.';

  @override
  String stockUsagePer(String quantity, String makes) {
    return '$quantity per $makes';
  }

  @override
  String stockUsageEach(String quantity) {
    return '$quantity each';
  }

  @override
  String get stockMoveReturned => 'Returned from deleted order';

  @override
  String get stockMoveReceived => 'Received';

  @override
  String get stockMoveUsed => 'Used in an order';

  @override
  String get stockMoveCounted => 'Counted';

  @override
  String get stockMoveWaste => 'Waste';

  @override
  String get stockNewTitle => 'New material';

  @override
  String get stockNameHint => 'e.g. Glass seed beads 2mm';

  @override
  String get stockNameRequired => 'Enter a name';

  @override
  String get stockCountedIn => 'Counted in';

  @override
  String get stockSectionBuy => 'How you buy it';

  @override
  String get stockPerPackLabel => 'Per pack';

  @override
  String stockUnitPerPackLabel(String unit) {
    return '$unit per pack';
  }

  @override
  String get stockPackPrice => 'Pack price';

  @override
  String get stockPriceRequired => 'Enter a price';

  @override
  String stockCostPerUnit(String cost, String unit) {
    return '$cost per $unit';
  }

  @override
  String get stockSectionStock => 'Stock';

  @override
  String get stockOnHandNow => 'On hand now';

  @override
  String stockUnitOnHandNow(String unit) {
    return '$unit on hand now';
  }

  @override
  String get stockReorderHelp =>
      'You’ll see a warning and it goes on the buy list when stock drops to the reorder level.';

  @override
  String get stockNumberAboveZero => 'Enter a number above 0';

  @override
  String get stockNumberZeroOrMore => 'Enter 0 or more';

  @override
  String get stockSaving => 'Saving…';

  @override
  String get stockSaveChanges => 'Save changes';

  @override
  String stockAdded(String name) {
    return '$name added';
  }

  @override
  String stockUpdated(String name) {
    return '$name updated';
  }
}
