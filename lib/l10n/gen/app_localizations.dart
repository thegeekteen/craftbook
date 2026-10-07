import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fil')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'CraftBook'**
  String get appName;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The language the app is shown in.'**
  String get languageSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFilipino.
  ///
  /// In en, this message translates to:
  /// **'Filipino (Tagalog)'**
  String get languageFilipino;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get commonArchive;

  /// No description provided for @commonUnarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get commonUnarchive;

  /// No description provided for @commonRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get commonRestore;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @commonOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get commonOn;

  /// No description provided for @commonOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get commonOff;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @commonNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commonNotes;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get commonLow;

  /// No description provided for @commonFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get commonFilter;

  /// No description provided for @commonNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get commonNotSet;

  /// No description provided for @commonClearField.
  ///
  /// In en, this message translates to:
  /// **'Clear {label}'**
  String commonClearField(String label);

  /// No description provided for @commonCouldntLoad.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load this'**
  String get commonCouldntLoad;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get navInventory;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dateTomorrow;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @dateInDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{In 1 day} other{In {count} days}}'**
  String dateInDays(int count);

  /// No description provided for @dateDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String dateDaysAgo(int count);

  /// No description provided for @moneySales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get moneySales;

  /// No description provided for @moneyDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get moneyDiscounts;

  /// No description provided for @moneyTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get moneyTax;

  /// No description provided for @moneyTaxInPrices.
  ///
  /// In en, this message translates to:
  /// **'{tax} in prices'**
  String moneyTaxInPrices(String tax);

  /// No description provided for @moneyMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get moneyMaterials;

  /// No description provided for @moneyChannelFees.
  ///
  /// In en, this message translates to:
  /// **'Channel fees'**
  String get moneyChannelFees;

  /// No description provided for @moneyShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get moneyShipping;

  /// No description provided for @moneyAddedTaxNote.
  ///
  /// In en, this message translates to:
  /// **'+ {amount} {tax} added for the customer to pay. It isn’t yours, so it’s not in profit.'**
  String moneyAddedTaxNote(String amount, String tax);

  /// No description provided for @moneyProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'Profit · {margin}% margin'**
  String moneyProfitMargin(int margin);

  /// No description provided for @moneyProfitSemantics.
  ///
  /// In en, this message translates to:
  /// **'Profit {profit} of {sales} sales'**
  String moneyProfitSemantics(String profit, String sales);

  /// No description provided for @pipFree.
  ///
  /// In en, this message translates to:
  /// **'free'**
  String get pipFree;

  /// No description provided for @pipPromised.
  ///
  /// In en, this message translates to:
  /// **'promised'**
  String get pipPromised;

  /// No description provided for @pipReorderLevel.
  ///
  /// In en, this message translates to:
  /// **'reorder level'**
  String get pipReorderLevel;

  /// No description provided for @productPhotoOf.
  ///
  /// In en, this message translates to:
  /// **'Photo of {name}'**
  String productPhotoOf(String name);

  /// No description provided for @appLogoLabel.
  ///
  /// In en, this message translates to:
  /// **'CraftBook logo'**
  String get appLogoLabel;

  /// No description provided for @noteToolRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get noteToolRedo;

  /// No description provided for @noteToolBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get noteToolBold;

  /// No description provided for @noteToolItalic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get noteToolItalic;

  /// No description provided for @noteToolUnderline.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get noteToolUnderline;

  /// No description provided for @noteToolStrikethrough.
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get noteToolStrikethrough;

  /// No description provided for @noteToolInlineCode.
  ///
  /// In en, this message translates to:
  /// **'Inline code'**
  String get noteToolInlineCode;

  /// No description provided for @noteToolHighlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get noteToolHighlight;

  /// No description provided for @noteToolLargeHeading.
  ///
  /// In en, this message translates to:
  /// **'Large heading'**
  String get noteToolLargeHeading;

  /// No description provided for @noteToolHeading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get noteToolHeading;

  /// No description provided for @noteToolSmallHeading.
  ///
  /// In en, this message translates to:
  /// **'Small heading'**
  String get noteToolSmallHeading;

  /// No description provided for @noteToolChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get noteToolChecklist;

  /// No description provided for @noteToolBulletList.
  ///
  /// In en, this message translates to:
  /// **'Bullet list'**
  String get noteToolBulletList;

  /// No description provided for @noteToolNumberedList.
  ///
  /// In en, this message translates to:
  /// **'Numbered list'**
  String get noteToolNumberedList;

  /// No description provided for @noteToolQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get noteToolQuote;

  /// No description provided for @noteToolCodeBlock.
  ///
  /// In en, this message translates to:
  /// **'Code block'**
  String get noteToolCodeBlock;

  /// No description provided for @noteToolOutdent.
  ///
  /// In en, this message translates to:
  /// **'Outdent'**
  String get noteToolOutdent;

  /// No description provided for @noteToolIndent.
  ///
  /// In en, this message translates to:
  /// **'Indent'**
  String get noteToolIndent;

  /// No description provided for @noteToolAlignCentre.
  ///
  /// In en, this message translates to:
  /// **'Align centre'**
  String get noteToolAlignCentre;

  /// No description provided for @noteToolAlignRight.
  ///
  /// In en, this message translates to:
  /// **'Align right'**
  String get noteToolAlignRight;

  /// No description provided for @noteToolLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get noteToolLink;

  /// No description provided for @noteToolClearFormatting.
  ///
  /// In en, this message translates to:
  /// **'Clear formatting'**
  String get noteToolClearFormatting;

  /// No description provided for @noteLinkAdd.
  ///
  /// In en, this message translates to:
  /// **'Add link'**
  String get noteLinkAdd;

  /// No description provided for @noteLinkEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit link'**
  String get noteLinkEdit;

  /// No description provided for @noteLinkAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get noteLinkAddress;

  /// No description provided for @noteLinkRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove link'**
  String get noteLinkRemove;

  /// No description provided for @noteHighlightSand.
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get noteHighlightSand;

  /// No description provided for @noteHighlightGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get noteHighlightGreen;

  /// No description provided for @noteHighlightLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get noteHighlightLavender;

  /// No description provided for @noteHighlightRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get noteHighlightRose;

  /// No description provided for @backupProblemNotSqlite.
  ///
  /// In en, this message translates to:
  /// **'This isn’t a Craftbook backup file.'**
  String get backupProblemNotSqlite;

  /// No description provided for @backupProblemCorrupt.
  ///
  /// In en, this message translates to:
  /// **'This backup is damaged and can’t be restored.'**
  String get backupProblemCorrupt;

  /// No description provided for @backupProblemWrongApp.
  ///
  /// In en, this message translates to:
  /// **'This file belongs to a different app, not Craftbook.'**
  String get backupProblemWrongApp;

  /// No description provided for @backupProblemNewerVersion.
  ///
  /// In en, this message translates to:
  /// **'This backup was made with a newer Craftbook. Update the app first.'**
  String get backupProblemNewerVersion;

  /// No description provided for @backupProblemUpgradeFailed.
  ///
  /// In en, this message translates to:
  /// **'This backup couldn’t be upgraded to this version of Craftbook.'**
  String get backupProblemUpgradeFailed;

  /// No description provided for @backupProblemSchemaMismatch.
  ///
  /// In en, this message translates to:
  /// **'This backup is missing data Craftbook needs.'**
  String get backupProblemSchemaMismatch;

  /// No description provided for @backupSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save backup'**
  String get backupSaveDialogTitle;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved successfully'**
  String get backupSaved;

  /// No description provided for @backupExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String backupExportFailed(String error);

  /// No description provided for @backupPickDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select backup file'**
  String get backupPickDialogTitle;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreMessage.
  ///
  /// In en, this message translates to:
  /// **'{summary}\n\nEverything on this phone is replaced by it. You can undo this from More.'**
  String backupRestoreMessage(String summary);

  /// No description provided for @backupContents.
  ///
  /// In en, this message translates to:
  /// **'{orders, plural, =1{1 order} other{{orders} orders}}, {materials, plural, =1{1 material} other{{materials} materials}} and {products, plural, =1{1 product} other{{products} products}}.'**
  String backupContents(int orders, int materials, int products);

  /// No description provided for @backupContentsUpgraded.
  ///
  /// In en, this message translates to:
  /// **'{contents} It was made with an older Craftbook and has been upgraded.'**
  String backupContentsUpgraded(String contents);

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupRestored;

  /// No description provided for @backupRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String backupRestoreFailed(String error);

  /// No description provided for @backupUndoTitle.
  ///
  /// In en, this message translates to:
  /// **'Undo last restore?'**
  String get backupUndoTitle;

  /// No description provided for @backupUndoMessage.
  ///
  /// In en, this message translates to:
  /// **'Goes back to the data you had before the last restore. Anything changed since then is lost.'**
  String get backupUndoMessage;

  /// No description provided for @backupUndoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Undo restore'**
  String get backupUndoConfirm;

  /// No description provided for @backupCantUndo.
  ///
  /// In en, this message translates to:
  /// **'Can’t undo: {reason}'**
  String backupCantUndo(String reason);

  /// No description provided for @backupRestoreUndone.
  ///
  /// In en, this message translates to:
  /// **'Restore undone'**
  String get backupRestoreUndone;

  /// No description provided for @backupUndoFailed.
  ///
  /// In en, this message translates to:
  /// **'Undo failed: {error}'**
  String backupUndoFailed(String error);

  /// No description provided for @backupSwapFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed, nothing was changed: {error}'**
  String backupSwapFailed(String error);

  /// No description provided for @backupRestartApp.
  ///
  /// In en, this message translates to:
  /// **'{message}. Restart the app.'**
  String backupRestartApp(String message);

  /// No description provided for @settingsMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get settingsMoreTitle;

  /// No description provided for @settingsSectionNotebook.
  ///
  /// In en, this message translates to:
  /// **'Notebook'**
  String get settingsSectionNotebook;

  /// No description provided for @settingsSectionShopOnline.
  ///
  /// In en, this message translates to:
  /// **'Your shop online'**
  String get settingsSectionShopOnline;

  /// No description provided for @settingsSectionCatalogue.
  ///
  /// In en, this message translates to:
  /// **'Catalogue'**
  String get settingsSectionCatalogue;

  /// No description provided for @settingsSectionMoneyOrders.
  ///
  /// In en, this message translates to:
  /// **'Money & orders'**
  String get settingsSectionMoneyOrders;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionYourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsSectionYourData;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get settingsNotesTitle;

  /// No description provided for @settingsNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Supplier details, ideas, how-tos'**
  String get settingsNotesHint;

  /// No description provided for @settingsSocialTitle.
  ///
  /// In en, this message translates to:
  /// **'Social shortcuts'**
  String get settingsSocialTitle;

  /// No description provided for @settingsSocialHint.
  ///
  /// In en, this message translates to:
  /// **'Facebook, TikTok, Shopee, Lazada…'**
  String get settingsSocialHint;

  /// No description provided for @settingsChannelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Channels & fees'**
  String get settingsChannelsTitle;

  /// No description provided for @settingsChannelsHint.
  ///
  /// In en, this message translates to:
  /// **'Where you sell and what they charge'**
  String get settingsChannelsHint;

  /// No description provided for @settingsOrderFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order fields'**
  String get settingsOrderFieldsTitle;

  /// No description provided for @settingsOrderFieldsHint.
  ///
  /// In en, this message translates to:
  /// **'Extra details to note on each order'**
  String get settingsOrderFieldsHint;

  /// No description provided for @settingsUnitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Units of measure'**
  String get settingsUnitsTitle;

  /// No description provided for @settingsUnitsHint.
  ///
  /// In en, this message translates to:
  /// **'What you count things in'**
  String get settingsUnitsHint;

  /// No description provided for @settingsBuyListTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy list'**
  String get settingsBuyListTitle;

  /// No description provided for @settingsBuyListHint.
  ///
  /// In en, this message translates to:
  /// **'Things to restock'**
  String get settingsBuyListHint;

  /// No description provided for @settingsReceivablesTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get settingsReceivablesTitle;

  /// No description provided for @settingsReceivablesHint.
  ///
  /// In en, this message translates to:
  /// **'Everyone has paid'**
  String get settingsReceivablesHint;

  /// No description provided for @settingsCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrencyTitle;

  /// No description provided for @settingsTaxTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get settingsTaxTitle;

  /// No description provided for @settingsDiscountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get settingsDiscountsTitle;

  /// No description provided for @settingsDiscountsHint.
  ///
  /// In en, this message translates to:
  /// **'Ones you give often'**
  String get settingsDiscountsHint;

  /// No description provided for @settingsExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsExportTitle;

  /// No description provided for @settingsExportHint.
  ///
  /// In en, this message translates to:
  /// **'Save a copy of everything to a file'**
  String get settingsExportHint;

  /// No description provided for @settingsRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get settingsRestoreTitle;

  /// No description provided for @settingsRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Replaces everything on this phone'**
  String get settingsRestoreHint;

  /// No description provided for @settingsUndoRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Undo last restore'**
  String get settingsUndoRestoreTitle;

  /// No description provided for @settingsUndoRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Go back to the data from before it'**
  String get settingsUndoRestoreHint;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Craftbook'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAboutHint.
  ///
  /// In en, this message translates to:
  /// **'What it does and how to use it'**
  String get settingsAboutHint;

  /// No description provided for @settingsFooterWithVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · all data stays on this phone'**
  String settingsFooterWithVersion(String version);

  /// No description provided for @settingsFooter.
  ///
  /// In en, this message translates to:
  /// **'All data stays on this phone'**
  String get settingsFooter;

  /// No description provided for @settingsChannelsOn.
  ///
  /// In en, this message translates to:
  /// **'{on} on'**
  String settingsChannelsOn(int on);

  /// No description provided for @settingsChannelsOnOff.
  ///
  /// In en, this message translates to:
  /// **'{on} on · {off} off'**
  String settingsChannelsOnOff(int on, int off);

  /// No description provided for @settingsFieldsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 field} other{{count} fields}}'**
  String settingsFieldsCount(int count);

  /// No description provided for @settingsArchivedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} archived'**
  String settingsArchivedCount(int count);

  /// No description provided for @settingsNothingToBuy.
  ///
  /// In en, this message translates to:
  /// **'Nothing to buy'**
  String get settingsNothingToBuy;

  /// No description provided for @settingsItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String settingsItemsCount(int count);

  /// No description provided for @settingsNotesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 note} other{{count} notes}}'**
  String settingsNotesCount(int count);

  /// No description provided for @settingsPinnedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pinned'**
  String settingsPinnedCount(int count);

  /// No description provided for @settingsOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 order} other{{count} orders}}'**
  String settingsOrdersCount(int count);

  /// No description provided for @settingsShortcutsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 shortcut} other{{count} shortcuts}}'**
  String settingsShortcutsCount(int count);

  /// No description provided for @settingsUnitsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} · new items start on {unit}'**
  String settingsUnitsSummary(int count, String unit);

  /// No description provided for @settingsTaxSummary.
  ///
  /// In en, this message translates to:
  /// **'{label} {rate}% · {mode}'**
  String settingsTaxSummary(String label, String rate, String mode);

  /// No description provided for @settingsTaxInPrices.
  ///
  /// In en, this message translates to:
  /// **'in prices'**
  String get settingsTaxInPrices;

  /// No description provided for @settingsTaxAddedOnTop.
  ///
  /// In en, this message translates to:
  /// **'added on top'**
  String get settingsTaxAddedOnTop;

  /// No description provided for @settingsTaxOffByDefault.
  ///
  /// In en, this message translates to:
  /// **'off by default'**
  String get settingsTaxOffByDefault;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load the guide. Please try again.'**
  String get aboutLoadFailed;

  /// No description provided for @appearanceColourScheme.
  ///
  /// In en, this message translates to:
  /// **'Colour scheme'**
  String get appearanceColourScheme;

  /// No description provided for @appearanceColourSchemeLabel.
  ///
  /// In en, this message translates to:
  /// **'{name} colour scheme'**
  String appearanceColourSchemeLabel(String name);

  /// No description provided for @appearancePaletteForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get appearancePaletteForest;

  /// No description provided for @appearancePaletteBerry.
  ///
  /// In en, this message translates to:
  /// **'Berry'**
  String get appearancePaletteBerry;

  /// No description provided for @appearancePaletteOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get appearancePaletteOcean;

  /// No description provided for @appearancePaletteSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get appearancePaletteSunset;

  /// No description provided for @appearanceDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get appearanceDarkMode;

  /// No description provided for @appearanceDarkAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Auto follows your phone'**
  String get appearanceDarkAutoHint;

  /// No description provided for @appearanceDarkOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'Overrides your phone setting'**
  String get appearanceDarkOverrideHint;

  /// No description provided for @appearanceAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get appearanceAuto;

  /// No description provided for @appearanceOrderCardsShow.
  ///
  /// In en, this message translates to:
  /// **'Order cards show'**
  String get appearanceOrderCardsShow;

  /// No description provided for @appearanceShowsTotalHint.
  ///
  /// In en, this message translates to:
  /// **'What the customer pays'**
  String get appearanceShowsTotalHint;

  /// No description provided for @appearanceShowsProfitHint.
  ///
  /// In en, this message translates to:
  /// **'What you keep after costs'**
  String get appearanceShowsProfitHint;

  /// No description provided for @appearanceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get appearanceTotal;

  /// No description provided for @appearanceProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get appearanceProfit;

  /// No description provided for @taxSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get taxSheetTitle;

  /// No description provided for @taxSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Works out the tax on each order so you know what to set aside.'**
  String get taxSheetSubtitle;

  /// No description provided for @taxExampleIncluded.
  ///
  /// In en, this message translates to:
  /// **'A {price} sale includes {tax} {name}. That comes out of your profit.'**
  String taxExampleIncluded(String price, String tax, String name);

  /// No description provided for @taxExampleOnTop.
  ///
  /// In en, this message translates to:
  /// **'A {price} sale costs the customer {total}. The {tax} {name} is theirs to pay, so it isn’t counted as profit.'**
  String taxExampleOnTop(String price, String total, String tax, String name);

  /// No description provided for @taxUse.
  ///
  /// In en, this message translates to:
  /// **'Use tax'**
  String get taxUse;

  /// No description provided for @taxUseOnHint.
  ///
  /// In en, this message translates to:
  /// **'Each order gets a tax switch'**
  String get taxUseOnHint;

  /// No description provided for @taxUseOffHint.
  ///
  /// In en, this message translates to:
  /// **'Orders have no tax. Saved orders keep what they had'**
  String get taxUseOffHint;

  /// No description provided for @taxNewOrders.
  ///
  /// In en, this message translates to:
  /// **'New orders start with tax'**
  String get taxNewOrders;

  /// No description provided for @taxNewOrdersOnHint.
  ///
  /// In en, this message translates to:
  /// **'Switch it off on orders that don’t need it'**
  String get taxNewOrdersOnHint;

  /// No description provided for @taxNewOrdersOffHint.
  ///
  /// In en, this message translates to:
  /// **'Switch it on when a customer needs it, like for an official receipt'**
  String get taxNewOrdersOffHint;

  /// No description provided for @taxCalled.
  ///
  /// In en, this message translates to:
  /// **'Called'**
  String get taxCalled;

  /// No description provided for @taxRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get taxRate;

  /// No description provided for @taxYourPrices.
  ///
  /// In en, this message translates to:
  /// **'Your prices'**
  String get taxYourPrices;

  /// No description provided for @taxIncluded.
  ///
  /// In en, this message translates to:
  /// **'Already include tax'**
  String get taxIncluded;

  /// No description provided for @taxOnTop.
  ///
  /// In en, this message translates to:
  /// **'Tax added on top'**
  String get taxOnTop;

  /// No description provided for @currencySheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencySheetTitle;

  /// No description provided for @currencySheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Changes the symbol only. Amounts aren’t converted.'**
  String get currencySheetSubtitle;

  /// No description provided for @currencySomethingElse.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get currencySomethingElse;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get currencySymbol;

  /// No description provided for @currencySymbolHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. kr'**
  String get currencySymbolHint;

  /// No description provided for @currencyUse.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get currencyUse;

  /// No description provided for @currencyNoCents.
  ///
  /// In en, this message translates to:
  /// **'No cents'**
  String get currencyNoCents;

  /// No description provided for @currencyNoCentsHint.
  ///
  /// In en, this message translates to:
  /// **'Show 1,200 instead of 1,200.00'**
  String get currencyNoCentsHint;

  /// No description provided for @pipSummary.
  ///
  /// In en, this message translates to:
  /// **'{free} free, {promised} promised'**
  String pipSummary(String free, String promised);

  /// No description provided for @pipSummaryReorder.
  ///
  /// In en, this message translates to:
  /// **'{free} free, {promised} promised, reorder at {level}'**
  String pipSummaryReorder(String free, String promised, String level);

  /// No description provided for @earningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get earningsTitle;

  /// No description provided for @earningsRangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get earningsRangeWeek;

  /// No description provided for @earningsRangeMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get earningsRangeMonth;

  /// No description provided for @earningsRangeYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get earningsRangeYear;

  /// No description provided for @earningsRangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get earningsRangeCustom;

  /// No description provided for @earningsPickerHelp.
  ///
  /// In en, this message translates to:
  /// **'Report on'**
  String get earningsPickerHelp;

  /// No description provided for @earningsPickerShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get earningsPickerShow;

  /// No description provided for @earningsPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get earningsPrevious;

  /// No description provided for @earningsOrders.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} order} other{{count} orders}}'**
  String earningsOrders(int count);

  /// No description provided for @earningsCustomers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} customer} other{{count} customers}}'**
  String earningsCustomers(int count);

  /// No description provided for @earningsDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} day} other{{count} days}}'**
  String earningsDays(int count);

  /// No description provided for @earningsNetProfit.
  ///
  /// In en, this message translates to:
  /// **'Net profit · {orders}'**
  String earningsNetProfit(String orders);

  /// No description provided for @earningsNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No packed or shipped orders in this period. Profit counts once an order is packed.'**
  String get earningsNoOrders;

  /// No description provided for @earningsNoOrdersFiltered.
  ///
  /// In en, this message translates to:
  /// **'No packed or shipped orders in this period match the filter.'**
  String get earningsNoOrdersFiltered;

  /// No description provided for @earningsMargin.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of sales is profit'**
  String earningsMargin(String percent);

  /// No description provided for @earningsUnpaidLine.
  ///
  /// In en, this message translates to:
  /// **'{amount} of it is still unpaid ({orders})'**
  String earningsUnpaidLine(String amount, String orders);

  /// No description provided for @earningsByProduct.
  ///
  /// In en, this message translates to:
  /// **'By product · {count}'**
  String earningsByProduct(int count);

  /// No description provided for @earningsSoldSales.
  ///
  /// In en, this message translates to:
  /// **'{sold} sold · {sales} sales'**
  String earningsSoldSales(String sold, String sales);

  /// No description provided for @earningsWaste.
  ///
  /// In en, this message translates to:
  /// **'Waste'**
  String get earningsWaste;

  /// No description provided for @earningsWasteWithCost.
  ///
  /// In en, this message translates to:
  /// **'Waste · {cost}'**
  String earningsWasteWithCost(String cost);

  /// No description provided for @earningsNoWaste.
  ///
  /// In en, this message translates to:
  /// **'No waste recorded in this period.'**
  String get earningsNoWaste;

  /// No description provided for @earningsWasted.
  ///
  /// In en, this message translates to:
  /// **'{quantity} wasted'**
  String earningsWasted(String quantity);

  /// No description provided for @earningsWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get earningsWaiting;

  /// No description provided for @earningsWaitingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{orders} · {customers}'**
  String earningsWaitingSubtitle(String orders, String customers);

  /// No description provided for @earningsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get earningsThisWeek;

  /// No description provided for @earningsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get earningsThisMonth;

  /// No description provided for @earningsThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get earningsThisYear;

  /// No description provided for @earningsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get earningsLastWeek;

  /// No description provided for @earningsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get earningsLastMonth;

  /// No description provided for @earningsProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get earningsProduct;

  /// No description provided for @earningsProductEarnings.
  ///
  /// In en, this message translates to:
  /// **'Product earnings'**
  String get earningsProductEarnings;

  /// No description provided for @earningsProfitCaption.
  ///
  /// In en, this message translates to:
  /// **'PROFIT'**
  String get earningsProfitCaption;

  /// No description provided for @earningsStatSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get earningsStatSold;

  /// No description provided for @earningsStatSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get earningsStatSales;

  /// No description provided for @earningsStatPerItem.
  ///
  /// In en, this message translates to:
  /// **'Per item'**
  String get earningsStatPerItem;

  /// No description provided for @earningsStatPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Per {unit}'**
  String earningsStatPerUnit(String unit);

  /// No description provided for @earningsOrdersHeader.
  ///
  /// In en, this message translates to:
  /// **'Orders · {count}'**
  String earningsOrdersHeader(int count);

  /// No description provided for @earningsNoProductOrders.
  ///
  /// In en, this message translates to:
  /// **'No packed or shipped orders with this product in this period.'**
  String get earningsNoProductOrders;

  /// No description provided for @earningsProfitSplitNote.
  ///
  /// In en, this message translates to:
  /// **'Each order’s profit is split across its products by share of sales.'**
  String get earningsProfitSplitNote;

  /// No description provided for @earningsFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter report'**
  String get earningsFilterTitle;

  /// No description provided for @earningsFilterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only orders that match every choice are counted.'**
  String get earningsFilterSubtitle;

  /// No description provided for @earningsFilterChannel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get earningsFilterChannel;

  /// No description provided for @earningsFilterProducts.
  ///
  /// In en, this message translates to:
  /// **'Has any of these products'**
  String get earningsFilterProducts;

  /// No description provided for @earningsFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get earningsFilterStatus;

  /// No description provided for @earningsFilterPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get earningsFilterPayment;

  /// No description provided for @earningsFilterDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get earningsFilterDiscount;

  /// No description provided for @earningsFilterTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get earningsFilterTax;

  /// No description provided for @earningsFilterTotal.
  ///
  /// In en, this message translates to:
  /// **'Order total'**
  String get earningsFilterTotal;

  /// No description provided for @earningsFilterFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get earningsFilterFrom;

  /// No description provided for @earningsFilterTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get earningsFilterTo;

  /// No description provided for @earningsFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get earningsFilterClear;

  /// No description provided for @earningsFilterShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get earningsFilterShow;

  /// No description provided for @earningsAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get earningsAny;

  /// No description provided for @earningsPacked.
  ///
  /// In en, this message translates to:
  /// **'Packed'**
  String get earningsPacked;

  /// No description provided for @earningsShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get earningsShipped;

  /// No description provided for @earningsPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get earningsPaid;

  /// No description provided for @earningsUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get earningsUnpaid;

  /// No description provided for @earningsWithDiscount.
  ///
  /// In en, this message translates to:
  /// **'With discount'**
  String get earningsWithDiscount;

  /// No description provided for @earningsNoDiscount.
  ///
  /// In en, this message translates to:
  /// **'No discount'**
  String get earningsNoDiscount;

  /// No description provided for @earningsWithTax.
  ///
  /// In en, this message translates to:
  /// **'With tax'**
  String get earningsWithTax;

  /// No description provided for @earningsNoTax.
  ///
  /// In en, this message translates to:
  /// **'No tax'**
  String get earningsNoTax;

  /// No description provided for @earningsChipChannel.
  ///
  /// In en, this message translates to:
  /// **'channel'**
  String get earningsChipChannel;

  /// No description provided for @earningsChipChannels.
  ///
  /// In en, this message translates to:
  /// **'{count} channels'**
  String earningsChipChannels(int count);

  /// No description provided for @earningsChipProduct.
  ///
  /// In en, this message translates to:
  /// **'product'**
  String get earningsChipProduct;

  /// No description provided for @earningsChipProducts.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String earningsChipProducts(int count);

  /// No description provided for @earningsChipPackedOnly.
  ///
  /// In en, this message translates to:
  /// **'Packed only'**
  String get earningsChipPackedOnly;

  /// No description provided for @earningsChipShippedOnly.
  ///
  /// In en, this message translates to:
  /// **'Shipped only'**
  String get earningsChipShippedOnly;

  /// No description provided for @earningsChipPackedOrShipped.
  ///
  /// In en, this message translates to:
  /// **'Packed or shipped'**
  String get earningsChipPackedOrShipped;

  /// No description provided for @earningsChipRange.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max}'**
  String earningsChipRange(String min, String max);

  /// No description provided for @earningsChipAndUp.
  ///
  /// In en, this message translates to:
  /// **'{min} and up'**
  String earningsChipAndUp(String min);

  /// No description provided for @earningsChipUpTo.
  ///
  /// In en, this message translates to:
  /// **'Up to {max}'**
  String earningsChipUpTo(String max);

  /// No description provided for @notesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get notesEmptyTitle;

  /// No description provided for @notesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep supplier details, product ideas and packing how-tos here.'**
  String get notesEmptyMessage;

  /// No description provided for @notesAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get notesAddNote;

  /// No description provided for @notesFab.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get notesFab;

  /// No description provided for @notesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get notesSearchHint;

  /// No description provided for @notesNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get notesNoMatches;

  /// No description provided for @notesNoMatchesMessage.
  ///
  /// In en, this message translates to:
  /// **'No note mentions \"{query}\".'**
  String notesNoMatchesMessage(String query);

  /// No description provided for @notesPinnedHeader.
  ///
  /// In en, this message translates to:
  /// **'Pinned · {count}'**
  String notesPinnedHeader(int count);

  /// No description provided for @notesOthersHeader.
  ///
  /// In en, this message translates to:
  /// **'Others · {count}'**
  String notesOthersHeader(int count);

  /// No description provided for @notesUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get notesUntitled;

  /// No description provided for @notesPinToToday.
  ///
  /// In en, this message translates to:
  /// **'Pin to Today'**
  String get notesPinToToday;

  /// No description provided for @notesUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get notesUnpin;

  /// No description provided for @notesPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get notesPin;

  /// No description provided for @notesPinnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get notesPinnedLabel;

  /// No description provided for @notesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get notesDeleteTitle;

  /// No description provided for @notesDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{title} is removed from your notebook.'**
  String notesDeleteMessage(String title);

  /// No description provided for @notesChecklistDone.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} done'**
  String notesChecklistDone(int done, int total);

  /// No description provided for @notesOutcomePinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned to Today'**
  String get notesOutcomePinned;

  /// No description provided for @notesOutcomeUnpinned.
  ///
  /// In en, this message translates to:
  /// **'Unpinned'**
  String get notesOutcomeUnpinned;

  /// No description provided for @notesOutcomeDeleted.
  ///
  /// In en, this message translates to:
  /// **'{title} deleted'**
  String notesOutcomeDeleted(String title);

  /// No description provided for @notesOutcomeRestored.
  ///
  /// In en, this message translates to:
  /// **'{title} restored'**
  String notesOutcomeRestored(String title);

  /// No description provided for @notesDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get notesDiscardTitle;

  /// No description provided for @notesDiscardNew.
  ///
  /// In en, this message translates to:
  /// **'The note is not saved.'**
  String get notesDiscardNew;

  /// No description provided for @notesDiscardEdit.
  ///
  /// In en, this message translates to:
  /// **'The note stays as it was.'**
  String get notesDiscardEdit;

  /// No description provided for @notesDiscardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get notesDiscardConfirm;

  /// No description provided for @notesKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get notesKeepEditing;

  /// No description provided for @notesNewNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get notesNewNote;

  /// No description provided for @notesEditNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get notesEditNote;

  /// No description provided for @notesMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get notesMore;

  /// No description provided for @notesTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notesTitleHint;

  /// No description provided for @notesBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Supplier details, ideas, how-tos…'**
  String get notesBodyHint;

  /// No description provided for @orderFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order fields'**
  String get orderFieldsTitle;

  /// No description provided for @orderFieldsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No order fields yet'**
  String get orderFieldsEmptyTitle;

  /// No description provided for @orderFieldsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add what you note on every order: address, size, gift message…'**
  String get orderFieldsEmptyMessage;

  /// No description provided for @orderFieldsAddField.
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get orderFieldsAddField;

  /// No description provided for @orderFieldsFab.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get orderFieldsFab;

  /// No description provided for @orderFieldsDragReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get orderFieldsDragReorder;

  /// No description provided for @orderFieldsArchivedHeader.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get orderFieldsArchivedHeader;

  /// No description provided for @orderFieldsDeleteNamed.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String orderFieldsDeleteNamed(String name);

  /// No description provided for @orderFieldsFooter.
  ///
  /// In en, this message translates to:
  /// **'Fields are asked for in this order when you add an order. Archived fields stay on past orders but aren’t asked for on new ones.'**
  String get orderFieldsFooter;

  /// No description provided for @orderFieldsEditField.
  ///
  /// In en, this message translates to:
  /// **'Edit field'**
  String get orderFieldsEditField;

  /// No description provided for @orderFieldsArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive {name}?'**
  String orderFieldsArchiveTitle(String name);

  /// No description provided for @orderFieldsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String orderFieldsDeleteTitle(String name);

  /// No description provided for @orderFieldsArchiveMessage.
  ///
  /// In en, this message translates to:
  /// **'It stays on {count, plural, =1{the 1 order} other{the {count} orders}} that use it, but won’t be asked for on new ones.'**
  String orderFieldsArchiveMessage(int count);

  /// No description provided for @orderFieldsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'No order uses it, so it is removed for good.'**
  String get orderFieldsDeleteMessage;

  /// No description provided for @orderFieldsNewField.
  ///
  /// In en, this message translates to:
  /// **'New order field'**
  String get orderFieldsNewField;

  /// No description provided for @orderFieldsEditNamed.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String orderFieldsEditNamed(String name);

  /// No description provided for @orderFieldsNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Address'**
  String get orderFieldsNameHint;

  /// No description provided for @orderFieldsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get orderFieldsNameRequired;

  /// No description provided for @orderFieldsTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get orderFieldsTypeLabel;

  /// No description provided for @orderFieldsTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get orderFieldsTypeText;

  /// No description provided for @orderFieldsTypeNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get orderFieldsTypeNumber;

  /// No description provided for @orderFieldsTypeDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get orderFieldsTypeDate;

  /// No description provided for @orderFieldsTypeChoice.
  ///
  /// In en, this message translates to:
  /// **'Choice'**
  String get orderFieldsTypeChoice;

  /// No description provided for @orderFieldsTypeLocked.
  ///
  /// In en, this message translates to:
  /// **'Type can’t change once orders use it.'**
  String get orderFieldsTypeLocked;

  /// No description provided for @orderFieldsNumberNote.
  ///
  /// In en, this message translates to:
  /// **'Numbers drop leading zeros. Use Text for phone numbers.'**
  String get orderFieldsNumberNote;

  /// No description provided for @orderFieldsMultiline.
  ///
  /// In en, this message translates to:
  /// **'Multi-line'**
  String get orderFieldsMultiline;

  /// No description provided for @orderFieldsMultilineHint.
  ///
  /// In en, this message translates to:
  /// **'For longer text like an address'**
  String get orderFieldsMultilineHint;

  /// No description provided for @orderFieldsChoices.
  ///
  /// In en, this message translates to:
  /// **'Choices'**
  String get orderFieldsChoices;

  /// No description provided for @orderFieldsChoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Choice {number}'**
  String orderFieldsChoiceHint(int number);

  /// No description provided for @orderFieldsChoiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one choice'**
  String get orderFieldsChoiceRequired;

  /// No description provided for @orderFieldsRemoveChoice.
  ///
  /// In en, this message translates to:
  /// **'Remove choice'**
  String get orderFieldsRemoveChoice;

  /// No description provided for @orderFieldsAddChoice.
  ///
  /// In en, this message translates to:
  /// **'Add choice'**
  String get orderFieldsAddChoice;

  /// No description provided for @orderFieldsChoicesKept.
  ///
  /// In en, this message translates to:
  /// **'Orders keep the choice they were saved with, even if you rename or remove it here.'**
  String get orderFieldsChoicesKept;

  /// No description provided for @orderFieldsEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get orderFieldsEnterNumber;

  /// No description provided for @orderFieldsChoiceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 choice} other{{count} choices}}'**
  String orderFieldsChoiceCount(int count);

  /// No description provided for @orderFieldsUsedOn.
  ///
  /// In en, this message translates to:
  /// **'used on {count, plural, =1{1 order} other{{count} orders}}'**
  String orderFieldsUsedOn(int count);

  /// No description provided for @orderFieldsNotUsed.
  ///
  /// In en, this message translates to:
  /// **'not used yet'**
  String get orderFieldsNotUsed;

  /// No description provided for @orderFieldsFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get orderFieldsFallbackName;

  /// No description provided for @orderFieldsOutcomeAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String orderFieldsOutcomeAdded(String name);

  /// No description provided for @orderFieldsOutcomeSaved.
  ///
  /// In en, this message translates to:
  /// **'{name} saved'**
  String orderFieldsOutcomeSaved(String name);

  /// No description provided for @orderFieldsOutcomeArchived.
  ///
  /// In en, this message translates to:
  /// **'{name} archived'**
  String orderFieldsOutcomeArchived(String name);

  /// No description provided for @orderFieldsOutcomeDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String orderFieldsOutcomeDeleted(String name);

  /// No description provided for @orderFieldsOutcomeRestored.
  ///
  /// In en, this message translates to:
  /// **'{name} restored'**
  String orderFieldsOutcomeRestored(String name);

  /// No description provided for @socialTitle.
  ///
  /// In en, this message translates to:
  /// **'Social shortcuts'**
  String get socialTitle;

  /// No description provided for @socialEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No shortcuts yet'**
  String get socialEmptyTitle;

  /// No description provided for @socialEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep your Facebook, TikTok, Shopee or Lazada page one tap away.'**
  String get socialEmptyMessage;

  /// No description provided for @socialAddShortcut.
  ///
  /// In en, this message translates to:
  /// **'Add shortcut'**
  String get socialAddShortcut;

  /// No description provided for @socialFab.
  ///
  /// In en, this message translates to:
  /// **'Shortcut'**
  String get socialFab;

  /// No description provided for @socialOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get socialOpen;

  /// No description provided for @socialEditShortcut.
  ///
  /// In en, this message translates to:
  /// **'Edit shortcut'**
  String get socialEditShortcut;

  /// No description provided for @socialRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String socialRemoveTitle(String name);

  /// No description provided for @socialRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'Only the shortcut goes; the page itself is untouched.'**
  String get socialRemoveMessage;

  /// No description provided for @socialHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a shortcut to open it in your browser or the app. Tap Edit to rearrange or change them.'**
  String get socialHint;

  /// No description provided for @socialNewShortcut.
  ///
  /// In en, this message translates to:
  /// **'New shortcut'**
  String get socialNewShortcut;

  /// No description provided for @socialEditNamed.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String socialEditNamed(String name);

  /// No description provided for @socialSite.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get socialSite;

  /// No description provided for @socialOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get socialOther;

  /// No description provided for @socialNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. My website'**
  String get socialNameHint;

  /// No description provided for @socialNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get socialNameRequired;

  /// No description provided for @socialLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get socialLinkLabel;

  /// No description provided for @socialLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a web address like {example}'**
  String socialLinkInvalid(String example);

  /// No description provided for @socialColour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get socialColour;

  /// No description provided for @socialCouldntOpen.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open {name}. Check the link.'**
  String socialCouldntOpen(String name);

  /// No description provided for @socialOpenNamed.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String socialOpenNamed(String name);

  /// No description provided for @socialDragReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get socialDragReorder;

  /// No description provided for @socialFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Shortcut'**
  String get socialFallbackName;

  /// No description provided for @socialOutcomeAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String socialOutcomeAdded(String name);

  /// No description provided for @socialOutcomeSaved.
  ///
  /// In en, this message translates to:
  /// **'{name} saved'**
  String socialOutcomeSaved(String name);

  /// No description provided for @socialOutcomeRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String socialOutcomeRemoved(String name);

  /// No description provided for @updatesCheck.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get updatesCheck;

  /// No description provided for @updatesCheckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get the newest version of Craftbook'**
  String get updatesCheckSubtitle;

  /// No description provided for @updatesChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get updatesChecking;

  /// No description provided for @updatesUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You’re on the newest version'**
  String get updatesUpToDate;

  /// No description provided for @updatesUpdateTo.
  ///
  /// In en, this message translates to:
  /// **'Update to {version}'**
  String updatesUpdateTo(String version);

  /// No description provided for @updatesTapToInstall.
  ///
  /// In en, this message translates to:
  /// **'Tap to download and install'**
  String get updatesTapToInstall;

  /// No description provided for @updatesDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get updatesDownloading;

  /// No description provided for @updatesDownloadingPercent.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String updatesDownloadingPercent(int percent);

  /// No description provided for @updatesFailedFallback.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Tap to try again.'**
  String get updatesFailedFallback;

  /// No description provided for @updatesDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Your orders, stock and notes stay as they are.'**
  String get updatesDialogMessage;

  /// No description provided for @updatesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updatesConfirm;

  /// No description provided for @updatesLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updatesLater;

  /// No description provided for @ordersStatusToPack.
  ///
  /// In en, this message translates to:
  /// **'To pack'**
  String get ordersStatusToPack;

  /// No description provided for @ordersStatusPacked.
  ///
  /// In en, this message translates to:
  /// **'Packed'**
  String get ordersStatusPacked;

  /// No description provided for @ordersStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get ordersStatusShipped;

  /// No description provided for @ordersStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersStatusCancelled;

  /// No description provided for @ordersOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get ordersOverdue;

  /// No description provided for @ordersPaymentAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get ordersPaymentAny;

  /// No description provided for @ordersPaymentUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get ordersPaymentUnpaid;

  /// No description provided for @ordersPaymentPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get ordersPaymentPaid;

  /// No description provided for @ordersFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter orders'**
  String get ordersFilterTitle;

  /// No description provided for @ordersFilterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Works together with the status chips and search.'**
  String get ordersFilterSubtitle;

  /// No description provided for @ordersFilterPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get ordersFilterPayment;

  /// No description provided for @ordersFilterClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get ordersFilterClearAll;

  /// No description provided for @ordersFilterShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get ordersFilterShow;

  /// No description provided for @ordersItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{qty} item} other{{qty} items}}'**
  String ordersItemCount(num count, String qty);

  /// No description provided for @ordersOrderCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 order} other{{count} orders}}'**
  String ordersOrderCount(int count);

  /// No description provided for @ordersLineCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line} other{{count} lines}}'**
  String ordersLineCount(int count);

  /// No description provided for @ordersMiniProfit.
  ///
  /// In en, this message translates to:
  /// **'{amount} profit'**
  String ordersMiniProfit(String amount);

  /// No description provided for @ordersUnpaidTag.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get ordersUnpaidTag;

  /// No description provided for @ordersDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get ordersDateToday;

  /// No description provided for @ordersDateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get ordersDateTomorrow;

  /// No description provided for @ordersDateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get ordersDateYesterday;

  /// No description provided for @ordersWhenShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get ordersWhenShipped;

  /// No description provided for @ordersWhenShippedOn.
  ///
  /// In en, this message translates to:
  /// **'Shipped {date}'**
  String ordersWhenShippedOn(String date);

  /// No description provided for @ordersWhenCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersWhenCancelled;

  /// No description provided for @ordersWhenDueYesterday.
  ///
  /// In en, this message translates to:
  /// **'Due yesterday'**
  String get ordersWhenDueYesterday;

  /// No description provided for @ordersWhenDueDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Due 1 day ago} other{Due {count} days ago}}'**
  String ordersWhenDueDaysAgo(int count);

  /// No description provided for @ordersWhenShipsToday.
  ///
  /// In en, this message translates to:
  /// **'Ships today'**
  String get ordersWhenShipsToday;

  /// No description provided for @ordersWhenShips.
  ///
  /// In en, this message translates to:
  /// **'Ships {date}'**
  String ordersWhenShips(String date);

  /// No description provided for @ordersActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Order #{id} · {customer}'**
  String ordersActionTitle(String id, String customer);

  /// No description provided for @ordersMarkShipped.
  ///
  /// In en, this message translates to:
  /// **'Mark shipped'**
  String get ordersMarkShipped;

  /// No description provided for @ordersMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark paid'**
  String get ordersMarkPaid;

  /// No description provided for @ordersMarkUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Mark unpaid'**
  String get ordersMarkUnpaid;

  /// No description provided for @ordersEditNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get ordersEditNote;

  /// No description provided for @ordersEditOrder.
  ///
  /// In en, this message translates to:
  /// **'Edit order'**
  String get ordersEditOrder;

  /// No description provided for @ordersCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get ordersCancelOrder;

  /// No description provided for @ordersRestoreOrder.
  ///
  /// In en, this message translates to:
  /// **'Restore order'**
  String get ordersRestoreOrder;

  /// No description provided for @ordersDeleteOrder.
  ///
  /// In en, this message translates to:
  /// **'Delete order'**
  String get ordersDeleteOrder;

  /// No description provided for @ordersToastShipped.
  ///
  /// In en, this message translates to:
  /// **'Marked as shipped'**
  String get ordersToastShipped;

  /// No description provided for @ordersToastPaid.
  ///
  /// In en, this message translates to:
  /// **'Marked as paid'**
  String get ordersToastPaid;

  /// No description provided for @ordersToastUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Marked as unpaid'**
  String get ordersToastUnpaid;

  /// No description provided for @ordersToastCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled. Stock returned.'**
  String get ordersToastCancelled;

  /// No description provided for @ordersToastRestored.
  ///
  /// In en, this message translates to:
  /// **'Order restored'**
  String get ordersToastRestored;

  /// No description provided for @ordersToastDeleted.
  ///
  /// In en, this message translates to:
  /// **'Order deleted'**
  String get ordersToastDeleted;

  /// No description provided for @ordersToastPacked.
  ///
  /// In en, this message translates to:
  /// **'Packed. Stock updated.'**
  String get ordersToastPacked;

  /// No description provided for @ordersToastMaterialsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Materials updated'**
  String get ordersToastMaterialsUpdated;

  /// No description provided for @ordersCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel order #{id}?'**
  String ordersCancelTitle(String id);

  /// No description provided for @ordersCancelMessageShipped.
  ///
  /// In en, this message translates to:
  /// **'Use this when it came back or never went out. Its materials go back on the shelf, and the order stays in your list as cancelled, out of your reports. You can delete it after.'**
  String get ordersCancelMessageShipped;

  /// No description provided for @ordersCancelMessagePacked.
  ///
  /// In en, this message translates to:
  /// **'Its materials go back on the shelf. The order stays in your list as cancelled and doesn’t count toward earnings.'**
  String get ordersCancelMessagePacked;

  /// No description provided for @ordersCancelMessagePending.
  ///
  /// In en, this message translates to:
  /// **'Its reserved stock is released. The order stays in your list as cancelled and doesn’t count toward earnings.'**
  String get ordersCancelMessagePending;

  /// No description provided for @ordersCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get ordersCancelConfirm;

  /// No description provided for @ordersCancelKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep order'**
  String get ordersCancelKeep;

  /// No description provided for @ordersRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore order #{id}?'**
  String ordersRestoreTitle(String id);

  /// No description provided for @ordersRestoreMessage.
  ///
  /// In en, this message translates to:
  /// **'It goes back to To pack and reserves its materials again.'**
  String get ordersRestoreMessage;

  /// No description provided for @ordersDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete order #{id}?'**
  String ordersDeleteTitle(String id);

  /// No description provided for @ordersDeleteMessagePacked.
  ///
  /// In en, this message translates to:
  /// **'The order is removed and its materials go back on the shelf.'**
  String get ordersDeleteMessagePacked;

  /// No description provided for @ordersDeleteMessageCancelled.
  ///
  /// In en, this message translates to:
  /// **'The cancelled order is removed for good.'**
  String get ordersDeleteMessageCancelled;

  /// No description provided for @ordersDeleteMessagePending.
  ///
  /// In en, this message translates to:
  /// **'The order is removed and its reserved stock is released.'**
  String get ordersDeleteMessagePending;

  /// No description provided for @ordersNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get ordersNoteOptional;

  /// No description provided for @ordersNotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Gift wrap, colour requests, packing steps…'**
  String get ordersNotePlaceholder;

  /// No description provided for @ordersNoteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get ordersNoteAdd;

  /// No description provided for @ordersDiscardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get ordersDiscardChangesTitle;

  /// No description provided for @ordersNoteStaysMessage.
  ///
  /// In en, this message translates to:
  /// **'The note stays as it was.'**
  String get ordersNoteStaysMessage;

  /// No description provided for @ordersDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get ordersDiscard;

  /// No description provided for @ordersKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get ordersKeepEditing;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersNewOrder.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get ordersNewOrder;

  /// No description provided for @ordersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name, # or channel'**
  String get ordersSearchHint;

  /// No description provided for @ordersGroupPacked.
  ///
  /// In en, this message translates to:
  /// **'Packed, ready to ship'**
  String get ordersGroupPacked;

  /// No description provided for @ordersGroupDueThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Due this week'**
  String get ordersGroupDueThisWeek;

  /// No description provided for @ordersGroupLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get ordersGroupLater;

  /// No description provided for @ordersEmptyNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmptyNoneTitle;

  /// No description provided for @ordersEmptyNoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Your first order will show up here.'**
  String get ordersEmptyNoneMessage;

  /// No description provided for @ordersNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get ordersNoMatches;

  /// No description provided for @ordersNoMatchesFor.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}”.'**
  String ordersNoMatchesFor(String query);

  /// No description provided for @ordersNothingWaiting.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting for payment'**
  String get ordersNothingWaiting;

  /// No description provided for @ordersNoPaidHere.
  ///
  /// In en, this message translates to:
  /// **'No paid orders here'**
  String get ordersNoPaidHere;

  /// No description provided for @ordersNothingToPack.
  ///
  /// In en, this message translates to:
  /// **'Nothing to pack'**
  String get ordersNothingToPack;

  /// No description provided for @ordersAllPackedMessage.
  ///
  /// In en, this message translates to:
  /// **'Every order is packed. Nice work.'**
  String get ordersAllPackedMessage;

  /// No description provided for @ordersNoStatusOrders.
  ///
  /// In en, this message translates to:
  /// **'No {status} orders'**
  String ordersNoStatusOrders(String status);

  /// No description provided for @ordersReceivablesTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get ordersReceivablesTitle;

  /// No description provided for @ordersReceivablesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Everyone has paid'**
  String get ordersReceivablesEmptyTitle;

  /// No description provided for @ordersReceivablesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Orders marked unpaid will show up here.'**
  String get ordersReceivablesEmptyMessage;

  /// No description provided for @ordersReceivablesOwed.
  ///
  /// In en, this message translates to:
  /// **'Owed to you · {orders}'**
  String ordersReceivablesOwed(String orders);

  /// No description provided for @ordersReceivablesHint.
  ///
  /// In en, this message translates to:
  /// **'Mark an order paid from its page or by long-pressing it.'**
  String get ordersReceivablesHint;

  /// No description provided for @ordersDetailHeader.
  ///
  /// In en, this message translates to:
  /// **'ORDER #{id}'**
  String ordersDetailHeader(String id);

  /// No description provided for @ordersMenuMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get ordersMenuMore;

  /// No description provided for @ordersItemsCaps.
  ///
  /// In en, this message translates to:
  /// **'ITEMS'**
  String get ordersItemsCaps;

  /// No description provided for @ordersPlaced.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get ordersPlaced;

  /// No description provided for @ordersPlacedOn.
  ///
  /// In en, this message translates to:
  /// **'Placed {date}'**
  String ordersPlacedOn(String date);

  /// No description provided for @ordersDueOn.
  ///
  /// In en, this message translates to:
  /// **'due {date}'**
  String ordersDueOn(String date);

  /// No description provided for @ordersCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get ordersCustomer;

  /// No description provided for @ordersFieldCopied.
  ///
  /// In en, this message translates to:
  /// **'{label} copied'**
  String ordersFieldCopied(String label);

  /// No description provided for @ordersDiscountsLine.
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get ordersDiscountsLine;

  /// No description provided for @ordersItemsLine.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get ordersItemsLine;

  /// No description provided for @ordersIncludesTax.
  ///
  /// In en, this message translates to:
  /// **'Includes {amount} {tax} ({rate}%)'**
  String ordersIncludesTax(String amount, String tax, String rate);

  /// No description provided for @ordersPaidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid {date}'**
  String ordersPaidOn(String date);

  /// No description provided for @ordersPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get ordersPaid;

  /// No description provided for @ordersWaitingForPayment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get ordersWaitingForPayment;

  /// No description provided for @ordersTotalCaps.
  ///
  /// In en, this message translates to:
  /// **'ORDER TOTAL'**
  String get ordersTotalCaps;

  /// No description provided for @ordersAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get ordersAdjust;

  /// No description provided for @ordersPackOrder.
  ///
  /// In en, this message translates to:
  /// **'Pack order'**
  String get ordersPackOrder;

  /// No description provided for @ordersMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get ordersMaterials;

  /// No description provided for @ordersMaterialsLines.
  ///
  /// In en, this message translates to:
  /// **'Materials · {lines}'**
  String ordersMaterialsLines(String lines);

  /// No description provided for @ordersMaterialsLinesWaste.
  ///
  /// In en, this message translates to:
  /// **'Materials · {lines} · waste'**
  String ordersMaterialsLinesWaste(String lines);

  /// No description provided for @ordersChannelFees.
  ///
  /// In en, this message translates to:
  /// **'Channel fees'**
  String get ordersChannelFees;

  /// No description provided for @ordersChannelFeesNamed.
  ///
  /// In en, this message translates to:
  /// **'{channel} fees'**
  String ordersChannelFeesNamed(String channel);

  /// No description provided for @ordersPlannedUsed.
  ///
  /// In en, this message translates to:
  /// **'Planned {planned} · used {used}'**
  String ordersPlannedUsed(String planned, String used);

  /// No description provided for @ordersWasteQty.
  ///
  /// In en, this message translates to:
  /// **'+{qty} waste'**
  String ordersWasteQty(String qty);

  /// No description provided for @ordersWasteQtyReason.
  ///
  /// In en, this message translates to:
  /// **'+{qty} waste ({reason})'**
  String ordersWasteQtyReason(String qty, String reason);

  /// No description provided for @ordersFromStock.
  ///
  /// In en, this message translates to:
  /// **'{qty} × {price} · from stock'**
  String ordersFromStock(String qty, String price);

  /// No description provided for @ordersWasteCutting.
  ///
  /// In en, this message translates to:
  /// **'Cutting'**
  String get ordersWasteCutting;

  /// No description provided for @ordersWasteDefect.
  ///
  /// In en, this message translates to:
  /// **'Defect'**
  String get ordersWasteDefect;

  /// No description provided for @ordersWasteMiscount.
  ///
  /// In en, this message translates to:
  /// **'Miscount'**
  String get ordersWasteMiscount;

  /// No description provided for @ordersWasteOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get ordersWasteOther;

  /// No description provided for @ordersAdjustTitle.
  ///
  /// In en, this message translates to:
  /// **'Materials used'**
  String get ordersAdjustTitle;

  /// No description provided for @ordersAdjustIntro.
  ///
  /// In en, this message translates to:
  /// **'Record what you actually used. Anything over plan counts as waste and comes out of this order’s profit.'**
  String get ordersAdjustIntro;

  /// No description provided for @ordersPlannedPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Planned {qty} · {price}/{unit}'**
  String ordersPlannedPerUnit(String qty, String price, String unit);

  /// No description provided for @ordersPlannedEach.
  ///
  /// In en, this message translates to:
  /// **'Planned {qty} · {price} each'**
  String ordersPlannedEach(String qty, String price);

  /// No description provided for @ordersWasteCost.
  ///
  /// In en, this message translates to:
  /// **'+{qty} waste · {cost}'**
  String ordersWasteCost(String qty, String cost);

  /// No description provided for @ordersWhy.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get ordersWhy;

  /// No description provided for @ordersFewerThanPlanned.
  ///
  /// In en, this message translates to:
  /// **'{qty} fewer than planned'**
  String ordersFewerThanPlanned(String qty);

  /// No description provided for @ordersPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Pack this order?'**
  String get ordersPackTitle;

  /// No description provided for @ordersPackNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing to take from stock for this order.'**
  String get ordersPackNothing;

  /// No description provided for @ordersPackIntro.
  ///
  /// In en, this message translates to:
  /// **'These pieces come off your shelf.'**
  String get ordersPackIntro;

  /// No description provided for @ordersPackShort.
  ///
  /// In en, this message translates to:
  /// **'Short on {names}.'**
  String ordersPackShort(String names);

  /// No description provided for @ordersPackShortMessage.
  ///
  /// In en, this message translates to:
  /// **'Stock will stop at 0.'**
  String get ordersPackShortMessage;

  /// No description provided for @ordersPackConfirm.
  ///
  /// In en, this message translates to:
  /// **'Pack & deduct'**
  String get ordersPackConfirm;

  /// No description provided for @ordersAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get ordersAddProduct;

  /// No description provided for @ordersSearchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get ordersSearchProducts;

  /// No description provided for @ordersNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get ordersNoProducts;

  /// No description provided for @ordersNoProductsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add products under More → Products first.'**
  String get ordersNoProductsMessage;

  /// No description provided for @ordersOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get ordersOutOfStock;

  /// No description provided for @ordersCantBuild.
  ///
  /// In en, this message translates to:
  /// **'Can’t build: not enough materials'**
  String get ordersCantBuild;

  /// No description provided for @ordersInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock {qty}'**
  String ordersInStock(String qty);

  /// No description provided for @ordersCanBuild.
  ///
  /// In en, this message translates to:
  /// **'Can build {qty}'**
  String ordersCanBuild(String qty);

  /// No description provided for @ordersAddedTag.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get ordersAddedTag;

  /// No description provided for @ordersDiscountsCaps.
  ///
  /// In en, this message translates to:
  /// **'DISCOUNTS'**
  String get ordersDiscountsCaps;

  /// No description provided for @ordersManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get ordersManage;

  /// No description provided for @ordersRemoveDiscount.
  ///
  /// In en, this message translates to:
  /// **'Remove {label}'**
  String ordersRemoveDiscount(String label);

  /// No description provided for @ordersAddDiscountChip.
  ///
  /// In en, this message translates to:
  /// **'+ Add discount'**
  String get ordersAddDiscountChip;

  /// No description provided for @ordersOtherDiscountChip.
  ///
  /// In en, this message translates to:
  /// **'+ Other'**
  String get ordersOtherDiscountChip;

  /// No description provided for @ordersAddDiscountTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a discount'**
  String get ordersAddDiscountTitle;

  /// No description provided for @ordersTaxInPrices.
  ///
  /// In en, this message translates to:
  /// **'{tax} {rate}% · in prices'**
  String ordersTaxInPrices(String tax, String rate);

  /// No description provided for @ordersTaxOnTop.
  ///
  /// In en, this message translates to:
  /// **'{tax} {rate}% · added on top'**
  String ordersTaxOnTop(String tax, String rate);

  /// No description provided for @ordersTaxOff.
  ///
  /// In en, this message translates to:
  /// **'Off for this order'**
  String get ordersTaxOff;

  /// No description provided for @ordersTaxPartOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{amount} of the total is {tax}'**
  String ordersTaxPartOfTotal(String amount, String tax);

  /// No description provided for @ordersTaxCustomerPays.
  ///
  /// In en, this message translates to:
  /// **'Customer pays {amount} more'**
  String ordersTaxCustomerPays(String amount);

  /// No description provided for @ordersPaidSwitch.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get ordersPaidSwitch;

  /// No description provided for @ordersPaidHasPaid.
  ///
  /// In en, this message translates to:
  /// **'The customer has paid'**
  String get ordersPaidHasPaid;

  /// No description provided for @ordersPaidWaitingFor.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {amount}'**
  String ordersPaidWaitingFor(String amount);

  /// No description provided for @ordersPickChannel.
  ///
  /// In en, this message translates to:
  /// **'Pick a sales channel'**
  String get ordersPickChannel;

  /// No description provided for @ordersDiscardEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard your changes?'**
  String get ordersDiscardEditTitle;

  /// No description provided for @ordersDiscardNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this order?'**
  String get ordersDiscardNewTitle;

  /// No description provided for @ordersDiscardEditMessage.
  ///
  /// In en, this message translates to:
  /// **'The order stays as it was.'**
  String get ordersDiscardEditMessage;

  /// No description provided for @ordersDiscardNewMessage.
  ///
  /// In en, this message translates to:
  /// **'What you’ve entered so far will be lost.'**
  String get ordersDiscardNewMessage;

  /// No description provided for @ordersSaved.
  ///
  /// In en, this message translates to:
  /// **'Order #{id} saved'**
  String ordersSaved(String id);

  /// No description provided for @ordersUpdated.
  ///
  /// In en, this message translates to:
  /// **'Order #{id} updated'**
  String ordersUpdated(String id);

  /// No description provided for @ordersEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit order'**
  String get ordersEditTitle;

  /// No description provided for @ordersEditTitleId.
  ///
  /// In en, this message translates to:
  /// **'Edit order #{id}'**
  String ordersEditTitleId(String id);

  /// No description provided for @ordersStepDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get ordersStepDetails;

  /// No description provided for @ordersStepCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get ordersStepCustomer;

  /// No description provided for @ordersStepItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get ordersStepItems;

  /// No description provided for @ordersStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get ordersStepReview;

  /// No description provided for @ordersCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get ordersCustomerName;

  /// No description provided for @ordersEnterCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Enter the customer name'**
  String get ordersEnterCustomerName;

  /// No description provided for @ordersAddOrderFields.
  ///
  /// In en, this message translates to:
  /// **'Add order fields (address, size…)'**
  String get ordersAddOrderFields;

  /// No description provided for @ordersChannel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get ordersChannel;

  /// No description provided for @ordersNoChannelsTitle.
  ///
  /// In en, this message translates to:
  /// **'No sales channels yet.'**
  String get ordersNoChannelsTitle;

  /// No description provided for @ordersNoChannelsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add one to work out fees.'**
  String get ordersNoChannelsMessage;

  /// No description provided for @ordersOrderDate.
  ///
  /// In en, this message translates to:
  /// **'Order date'**
  String get ordersOrderDate;

  /// No description provided for @ordersShipBy.
  ///
  /// In en, this message translates to:
  /// **'Ship by'**
  String get ordersShipBy;

  /// No description provided for @ordersNoItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get ordersNoItemsTitle;

  /// No description provided for @ordersNoItemsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add the products this customer ordered.'**
  String get ordersNoItemsMessage;

  /// No description provided for @ordersEachSubtotal.
  ///
  /// In en, this message translates to:
  /// **'{price} each · {subtotal}'**
  String ordersEachSubtotal(String price, String subtotal);

  /// No description provided for @ordersRemoveHint.
  ///
  /// In en, this message translates to:
  /// **'Set a quantity to 0 to remove it.'**
  String get ordersRemoveHint;

  /// No description provided for @ordersShipsByItems.
  ///
  /// In en, this message translates to:
  /// **'Ships by {date} · {items}'**
  String ordersShipsByItems(String date, String items);

  /// No description provided for @ordersShortBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock for some pieces.'**
  String get ordersShortBannerTitle;

  /// No description provided for @ordersShortBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'You can still save; the buy list will show what to get.'**
  String get ordersShortBannerMessage;

  /// No description provided for @ordersSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get ordersSaving;

  /// No description provided for @ordersSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get ordersSaveChanges;

  /// No description provided for @ordersSaveOrder.
  ///
  /// In en, this message translates to:
  /// **'Save order'**
  String get ordersSaveOrder;

  /// No description provided for @ordersNextAddItems.
  ///
  /// In en, this message translates to:
  /// **'Next: add items'**
  String get ordersNextAddItems;

  /// No description provided for @ordersReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get ordersReview;

  /// No description provided for @ordersTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ordersTotal;

  /// No description provided for @ordersReservesCaps.
  ///
  /// In en, this message translates to:
  /// **'RESERVES FROM STOCK'**
  String get ordersReservesCaps;

  /// No description provided for @ordersOnlyFree.
  ///
  /// In en, this message translates to:
  /// **'{qty} · only {free} free'**
  String ordersOnlyFree(String qty, String free);

  /// No description provided for @ordersLastOne.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{qty} · last one} other{{qty} · last ones}}'**
  String ordersLastOne(num count, String qty);

  /// No description provided for @todayToPackToday.
  ///
  /// In en, this message translates to:
  /// **'To pack today'**
  String get todayToPackToday;

  /// No description provided for @todayNewToday.
  ///
  /// In en, this message translates to:
  /// **'New today'**
  String get todayNewToday;

  /// No description provided for @todayWeekProfit.
  ///
  /// In en, this message translates to:
  /// **'Week profit'**
  String get todayWeekProfit;

  /// No description provided for @todayCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get todayCalendar;

  /// No description provided for @todayLowStock.
  ///
  /// In en, this message translates to:
  /// **'{count} low:'**
  String todayLowStock(int count);

  /// No description provided for @todayBuyList.
  ///
  /// In en, this message translates to:
  /// **'Buy list'**
  String get todayBuyList;

  /// No description provided for @todayPinnedNotes.
  ///
  /// In en, this message translates to:
  /// **'Pinned notes · {count}'**
  String todayPinnedNotes(int count);

  /// No description provided for @todayAllNotes.
  ///
  /// In en, this message translates to:
  /// **'All notes'**
  String get todayAllNotes;

  /// No description provided for @todayShipsToday.
  ///
  /// In en, this message translates to:
  /// **'Ships today · {count}'**
  String todayShipsToday(int count);

  /// No description provided for @todayNewTodaySection.
  ///
  /// In en, this message translates to:
  /// **'New today · {count}'**
  String todayNewTodaySection(int count);

  /// No description provided for @todayAllClear.
  ///
  /// In en, this message translates to:
  /// **'All clear for today'**
  String get todayAllClear;

  /// No description provided for @todayAllClearMessage.
  ///
  /// In en, this message translates to:
  /// **'Orders shipping today and new orders show up here.'**
  String get todayAllClearMessage;

  /// No description provided for @todayNoFilterMatch.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches this filter'**
  String get todayNoFilterMatch;

  /// No description provided for @todayPickAnotherStatus.
  ///
  /// In en, this message translates to:
  /// **'Pick another status or tap All.'**
  String get todayPickAnotherStatus;

  /// No description provided for @todayNoteDeleted.
  ///
  /// In en, this message translates to:
  /// **'{title} deleted'**
  String todayNoteDeleted(String title);

  /// No description provided for @todayPrevWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get todayPrevWeek;

  /// No description provided for @todayNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get todayNextWeek;

  /// No description provided for @todayPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get todayPrevMonth;

  /// No description provided for @todayNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get todayNextMonth;

  /// No description provided for @todayWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get todayWeek;

  /// No description provided for @todayMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get todayMonth;

  /// No description provided for @todayNothingDue.
  ///
  /// In en, this message translates to:
  /// **'Nothing due'**
  String get todayNothingDue;

  /// No description provided for @todayNothingShipsDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing ships this day.'**
  String get todayNothingShipsDay;

  /// No description provided for @todayDayOrders.
  ///
  /// In en, this message translates to:
  /// **'{date} · {orders}'**
  String todayDayOrders(String date, String orders);

  /// No description provided for @productsInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get productsInventoryTitle;

  /// No description provided for @productsTabProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTabProducts;

  /// No description provided for @productsTabMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get productsTabMaterials;

  /// No description provided for @productsFabProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productsFabProduct;

  /// No description provided for @productsFabMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get productsFabMaterial;

  /// No description provided for @productsTypeAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get productsTypeAny;

  /// No description provided for @productsTypeHandmade.
  ///
  /// In en, this message translates to:
  /// **'Handmade'**
  String get productsTypeHandmade;

  /// No description provided for @productsTypeResell.
  ///
  /// In en, this message translates to:
  /// **'Resell'**
  String get productsTypeResell;

  /// No description provided for @productsStockAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get productsStockAny;

  /// No description provided for @productsStockLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get productsStockLow;

  /// No description provided for @productsStockShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get productsStockShort;

  /// No description provided for @productsStockArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get productsStockArchived;

  /// No description provided for @productsFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter products'**
  String get productsFilterTitle;

  /// No description provided for @productsFilterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Works together with search.'**
  String get productsFilterSubtitle;

  /// No description provided for @productsFilterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get productsFilterType;

  /// No description provided for @productsFilterStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get productsFilterStock;

  /// No description provided for @productsFilterClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get productsFilterClearAll;

  /// No description provided for @productsFilterShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get productsFilterShow;

  /// No description provided for @productsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get productsSearchHint;

  /// No description provided for @productsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get productsEmptyTitle;

  /// No description provided for @productsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add what you sell and the materials it is made from.'**
  String get productsEmptyMessage;

  /// No description provided for @productsAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get productsAddProduct;

  /// No description provided for @productsNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get productsNoMatches;

  /// No description provided for @productsNoMatchesFor.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches \"{query}\".'**
  String productsNoMatchesFor(String query);

  /// No description provided for @productsNoFilterMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters'**
  String get productsNoFilterMatchTitle;

  /// No description provided for @productsNoFilterMatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap a filter above to remove it.'**
  String get productsNoFilterMatchMessage;

  /// No description provided for @productsNoHandmadeTitle.
  ///
  /// In en, this message translates to:
  /// **'No handmade products'**
  String get productsNoHandmadeTitle;

  /// No description provided for @productsNoHandmadeMessage.
  ///
  /// In en, this message translates to:
  /// **'Products made from your materials show up here.'**
  String get productsNoHandmadeMessage;

  /// No description provided for @productsNoResellTitle.
  ///
  /// In en, this message translates to:
  /// **'No resell products'**
  String get productsNoResellTitle;

  /// No description provided for @productsNoResellMessage.
  ///
  /// In en, this message translates to:
  /// **'Things you buy ready-made and sell on show up here.'**
  String get productsNoResellMessage;

  /// No description provided for @productsAllArchivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Every product is archived'**
  String get productsAllArchivedTitle;

  /// No description provided for @productsAllArchivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Filter by Archived to see them.'**
  String get productsAllArchivedMessage;

  /// No description provided for @productsNothingLowTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing is low'**
  String get productsNothingLowTitle;

  /// No description provided for @productsNothingLowMessage.
  ///
  /// In en, this message translates to:
  /// **'Set a warning level on a product to watch it here.'**
  String get productsNothingLowMessage;

  /// No description provided for @productsActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get productsActionEdit;

  /// No description provided for @productsActionReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive stock'**
  String get productsActionReceive;

  /// No description provided for @productsActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get productsActionDelete;

  /// No description provided for @productsArchivedSnack.
  ///
  /// In en, this message translates to:
  /// **'{name} archived'**
  String productsArchivedSnack(String name);

  /// No description provided for @productsUnarchivedSnack.
  ///
  /// In en, this message translates to:
  /// **'{name} is back in your lists'**
  String productsUnarchivedSnack(String name);

  /// No description provided for @productsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String productsDeleteTitle(String name);

  /// No description provided for @productsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This can’t be undone. Products that appear in orders can’t be deleted; archive them instead.'**
  String get productsDeleteMessage;

  /// No description provided for @productsDeletedSnack.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productsDeletedSnack;

  /// No description provided for @productsTagResell.
  ///
  /// In en, this message translates to:
  /// **'Resell'**
  String get productsTagResell;

  /// No description provided for @productsTagArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get productsTagArchived;

  /// No description provided for @productsTagShortForOrders.
  ///
  /// In en, this message translates to:
  /// **'Short for orders'**
  String get productsTagShortForOrders;

  /// No description provided for @productsCardCost.
  ///
  /// In en, this message translates to:
  /// **'Cost {cost}'**
  String productsCardCost(String cost);

  /// No description provided for @productsCardMargin.
  ///
  /// In en, this message translates to:
  /// **'{percent}% margin'**
  String productsCardMargin(String percent);

  /// No description provided for @productsInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get productsInStock;

  /// No description provided for @productsCanBuild.
  ///
  /// In en, this message translates to:
  /// **'Can build'**
  String get productsCanBuild;

  /// No description provided for @productsPhotoOf.
  ///
  /// In en, this message translates to:
  /// **'Photo of {name}'**
  String productsPhotoOf(String name);

  /// No description provided for @productsOnHandCaps.
  ///
  /// In en, this message translates to:
  /// **'ON HAND'**
  String get productsOnHandCaps;

  /// No description provided for @productsUnitOnHandCaps.
  ///
  /// In en, this message translates to:
  /// **'{unit} ON HAND'**
  String productsUnitOnHandCaps(String unit);

  /// No description provided for @productsCanBuildCaps.
  ///
  /// In en, this message translates to:
  /// **'CAN BUILD'**
  String get productsCanBuildCaps;

  /// No description provided for @productsStatShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get productsStatShort;

  /// No description provided for @productsStatFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get productsStatFree;

  /// No description provided for @productsStatPromised.
  ///
  /// In en, this message translates to:
  /// **'Promised'**
  String get productsStatPromised;

  /// No description provided for @productsStatReorderAt.
  ///
  /// In en, this message translates to:
  /// **'Reorder at'**
  String get productsStatReorderAt;

  /// No description provided for @productsStatWarnAt.
  ///
  /// In en, this message translates to:
  /// **'Warn at'**
  String get productsStatWarnAt;

  /// No description provided for @productsStatSellPrice.
  ///
  /// In en, this message translates to:
  /// **'Sell price'**
  String get productsStatSellPrice;

  /// No description provided for @productsStatCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get productsStatCost;

  /// No description provided for @productsStatMargin.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get productsStatMargin;

  /// No description provided for @productsProfitPerItem.
  ///
  /// In en, this message translates to:
  /// **'PROFIT PER ITEM'**
  String get productsProfitPerItem;

  /// No description provided for @productsProfitPerUnit.
  ///
  /// In en, this message translates to:
  /// **'PROFIT PER {unit}'**
  String productsProfitPerUnit(String unit);

  /// No description provided for @productsProfitNote.
  ///
  /// In en, this message translates to:
  /// **'{cost} {kind, select, resell{cost} other{materials}} · {margin}% margin · before channel fees'**
  String productsProfitNote(String cost, String kind, String margin);

  /// No description provided for @productsPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Product photo'**
  String get productsPhotoTitle;

  /// No description provided for @productsPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shown when you pick products for an order.'**
  String get productsPhotoSubtitle;

  /// No description provided for @productsPhotoTake.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get productsPhotoTake;

  /// No description provided for @productsPhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get productsPhotoGallery;

  /// No description provided for @productsPhotoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get productsPhotoRemove;

  /// No description provided for @productsPhotoCameraFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the camera'**
  String get productsPhotoCameraFailed;

  /// No description provided for @productsPhotoGalleryFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open your photos'**
  String get productsPhotoGalleryFailed;

  /// No description provided for @productsPhotoAdd.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get productsPhotoAdd;

  /// No description provided for @productsPhotoChange.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get productsPhotoChange;

  /// No description provided for @productsPhotoHelp.
  ///
  /// In en, this message translates to:
  /// **'Helps you spot the right item when making an order.'**
  String get productsPhotoHelp;

  /// No description provided for @productsHistInitial.
  ///
  /// In en, this message translates to:
  /// **'Initial stock'**
  String get productsHistInitial;

  /// No description provided for @productsHistReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned from deleted order'**
  String get productsHistReturned;

  /// No description provided for @productsHistReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get productsHistReceived;

  /// No description provided for @productsHistUsed.
  ///
  /// In en, this message translates to:
  /// **'Used in an order'**
  String get productsHistUsed;

  /// No description provided for @productsHistCounted.
  ///
  /// In en, this message translates to:
  /// **'Counted'**
  String get productsHistCounted;

  /// No description provided for @productsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productsNotFound;

  /// No description provided for @productsCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Count stock'**
  String get productsCountTitle;

  /// No description provided for @productsCountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set how many are actually on the shelf.'**
  String get productsCountSubtitle;

  /// No description provided for @productsCountSave.
  ///
  /// In en, this message translates to:
  /// **'Save count'**
  String get productsCountSave;

  /// No description provided for @productsStockSet.
  ///
  /// In en, this message translates to:
  /// **'Stock set to {qty}'**
  String productsStockSet(String qty);

  /// No description provided for @productsReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get productsReceive;

  /// No description provided for @productsCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get productsCount;

  /// No description provided for @productsMaterialsPerItem.
  ///
  /// In en, this message translates to:
  /// **'Materials per item · {count}'**
  String productsMaterialsPerItem(String count);

  /// No description provided for @productsMaterialsPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Materials per {unit} · {count}'**
  String productsMaterialsPerUnit(String unit, String count);

  /// No description provided for @productsNoMaterialsYet.
  ///
  /// In en, this message translates to:
  /// **'No materials yet. Edit the product to add them.'**
  String get productsNoMaterialsYet;

  /// No description provided for @productsMakesCount.
  ///
  /// In en, this message translates to:
  /// **'makes {makes}'**
  String productsMakesCount(String makes);

  /// No description provided for @productsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get productsHistoryTitle;

  /// No description provided for @productsHistoryError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load history: {error}'**
  String productsHistoryError(String error);

  /// No description provided for @productsHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sales or stock changes yet.'**
  String get productsHistoryEmpty;

  /// No description provided for @productsReceiveCaps.
  ///
  /// In en, this message translates to:
  /// **'RECEIVE'**
  String get productsReceiveCaps;

  /// No description provided for @productsQuantityReceivedCaps.
  ///
  /// In en, this message translates to:
  /// **'QUANTITY RECEIVED'**
  String get productsQuantityReceivedCaps;

  /// No description provided for @productsPriceEach.
  ///
  /// In en, this message translates to:
  /// **'Price each'**
  String get productsPriceEach;

  /// No description provided for @productsPricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Price per {unit}'**
  String productsPricePerUnit(String unit);

  /// No description provided for @productsAfterReceivingCaps.
  ///
  /// In en, this message translates to:
  /// **'AFTER RECEIVING'**
  String get productsAfterReceivingCaps;

  /// No description provided for @productsUnitCostWeighted.
  ///
  /// In en, this message translates to:
  /// **'Unit cost (weighted)'**
  String get productsUnitCostWeighted;

  /// No description provided for @productsReceivedSnack.
  ///
  /// In en, this message translates to:
  /// **'Added {qty} to {name}'**
  String productsReceivedSnack(String qty, String name);

  /// No description provided for @productsReceiveButton.
  ///
  /// In en, this message translates to:
  /// **'Add {qty} to stock'**
  String productsReceiveButton(String qty);

  /// No description provided for @productsNewProduct.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get productsNewProduct;

  /// No description provided for @productsEditProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get productsEditProduct;

  /// No description provided for @productsEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get productsEnterName;

  /// No description provided for @productsDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get productsDescriptionOptional;

  /// No description provided for @productsPriceAboveZero.
  ///
  /// In en, this message translates to:
  /// **'Enter a price above 0'**
  String get productsPriceAboveZero;

  /// No description provided for @productsSoldCountedIn.
  ///
  /// In en, this message translates to:
  /// **'Sold and counted in'**
  String get productsSoldCountedIn;

  /// No description provided for @productsLockOrders.
  ///
  /// In en, this message translates to:
  /// **'Used in orders, so its type is fixed.'**
  String get productsLockOrders;

  /// No description provided for @productsLockStock.
  ///
  /// In en, this message translates to:
  /// **'It has stock on hand or reserved, so its type is fixed.'**
  String get productsLockStock;

  /// No description provided for @productsLockBom.
  ///
  /// In en, this message translates to:
  /// **'Remove its materials first to switch it to Resell.'**
  String get productsLockBom;

  /// No description provided for @productsTypeHintResell.
  ///
  /// In en, this message translates to:
  /// **'Bought ready-made. Tracks its own stock.'**
  String get productsTypeHintResell;

  /// No description provided for @productsTypeHintHandmade.
  ///
  /// In en, this message translates to:
  /// **'Made from materials. Stock comes from what you can build.'**
  String get productsTypeHintHandmade;

  /// No description provided for @productsSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get productsSaving;

  /// No description provided for @productsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get productsSaveChanges;

  /// No description provided for @productsAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String productsAddedSnack(String name);

  /// No description provided for @productsChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get productsChangesSaved;

  /// No description provided for @productsMakesAboveZero.
  ///
  /// In en, this message translates to:
  /// **'{material}: Makes must be above 0'**
  String productsMakesAboveZero(String material);

  /// No description provided for @productsCostPerItem.
  ///
  /// In en, this message translates to:
  /// **'Cost per item'**
  String get productsCostPerItem;

  /// No description provided for @productsCostPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Cost per {unit}'**
  String productsCostPerUnit(String unit);

  /// No description provided for @productsMaterialsPerItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Materials per item'**
  String get productsMaterialsPerItemLabel;

  /// No description provided for @productsMaterialsPerUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Materials per {unit}'**
  String productsMaterialsPerUnitLabel(String unit);

  /// No description provided for @productsAddMaterialTitle.
  ///
  /// In en, this message translates to:
  /// **'Add material'**
  String get productsAddMaterialTitle;

  /// No description provided for @productsNoMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'No materials yet'**
  String get productsNoMaterialsTitle;

  /// No description provided for @productsAllMaterialsAdded.
  ///
  /// In en, this message translates to:
  /// **'All materials added'**
  String get productsAllMaterialsAdded;

  /// No description provided for @productsAddMaterialsFirst.
  ///
  /// In en, this message translates to:
  /// **'Add materials under Stock first.'**
  String get productsAddMaterialsFirst;

  /// No description provided for @productsSearchMaterials.
  ///
  /// In en, this message translates to:
  /// **'Search materials'**
  String get productsSearchMaterials;

  /// No description provided for @productsAddMaterialsHint.
  ///
  /// In en, this message translates to:
  /// **'Add what this is made from so the app can work out its cost and reserve stock.'**
  String get productsAddMaterialsHint;

  /// No description provided for @productsCostEach.
  ///
  /// In en, this message translates to:
  /// **'{cost} each'**
  String productsCostEach(String cost);

  /// No description provided for @productsUses.
  ///
  /// In en, this message translates to:
  /// **'Uses'**
  String get productsUses;

  /// No description provided for @productsMakes.
  ///
  /// In en, this message translates to:
  /// **'Makes'**
  String get productsMakes;

  /// No description provided for @productsBomHelp.
  ///
  /// In en, this message translates to:
  /// **'Uses is how much of the material goes in, Makes is how many of this product that makes (1 sheet makes 9 cards). Set Uses to 0 to remove a material.'**
  String get productsBomHelp;

  /// No description provided for @productsReorderAtOptional.
  ///
  /// In en, this message translates to:
  /// **'Reorder at (optional)'**
  String get productsReorderAtOptional;

  /// No description provided for @productsWarnWhenCanMake.
  ///
  /// In en, this message translates to:
  /// **'Warn when I can make (optional)'**
  String get productsWarnWhenCanMake;

  /// No description provided for @productsReorderHelp.
  ///
  /// In en, this message translates to:
  /// **'Warn when stock drops to this.'**
  String get productsReorderHelp;

  /// No description provided for @productsWarnHelp.
  ///
  /// In en, this message translates to:
  /// **'Warn when materials only cover this many.'**
  String get productsWarnHelp;

  /// No description provided for @productsStockSection.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get productsStockSection;

  /// No description provided for @productsCostRecalc.
  ///
  /// In en, this message translates to:
  /// **'Receiving stock recalculates this as an average.'**
  String get productsCostRecalc;

  /// No description provided for @productsOnHandNow.
  ///
  /// In en, this message translates to:
  /// **'On hand now'**
  String get productsOnHandNow;

  /// No description provided for @productsChannelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Channels & fees'**
  String get productsChannelsTitle;

  /// No description provided for @productsChannelAdded.
  ///
  /// In en, this message translates to:
  /// **'Channel added'**
  String get productsChannelAdded;

  /// No description provided for @productsChannelDeleted.
  ///
  /// In en, this message translates to:
  /// **'Channel deleted'**
  String get productsChannelDeleted;

  /// No description provided for @productsChannelsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No channels yet'**
  String get productsChannelsEmptyTitle;

  /// No description provided for @productsChannelsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add Shopee, TikTok Shop, walk-in… with their fees so profit is accurate.'**
  String get productsChannelsEmptyMessage;

  /// No description provided for @productsChannelAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add channel'**
  String get productsChannelAddButton;

  /// No description provided for @productsChannelsNote.
  ///
  /// In en, this message translates to:
  /// **'Examples use a {sale} sale. Turned-off channels stay on past orders but are hidden when you create new ones.'**
  String productsChannelsNote(String sale);

  /// No description provided for @productsChannelFab.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get productsChannelFab;

  /// No description provided for @productsChannelEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit channel'**
  String get productsChannelEdit;

  /// No description provided for @productsChannelDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete channel'**
  String get productsChannelDelete;

  /// No description provided for @productsChannelTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get productsChannelTurnOff;

  /// No description provided for @productsChannelTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get productsChannelTurnOn;

  /// No description provided for @productsChannelDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String productsChannelDeleteTitle(String name);

  /// No description provided for @productsChannelDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Channels used by orders can’t be deleted. Turn them off instead.'**
  String get productsChannelDeleteMessage;

  /// No description provided for @productsChannelNew.
  ///
  /// In en, this message translates to:
  /// **'New channel'**
  String get productsChannelNew;

  /// No description provided for @productsChannelEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String productsChannelEditTitle(String name);

  /// No description provided for @productsChannelNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Shopee'**
  String get productsChannelNameHint;

  /// No description provided for @productsChannelCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get productsChannelCommission;

  /// No description provided for @productsChannelTransactionFee.
  ///
  /// In en, this message translates to:
  /// **'Transaction fee'**
  String get productsChannelTransactionFee;

  /// No description provided for @productsChannelFixedFee.
  ///
  /// In en, this message translates to:
  /// **'Fixed fee'**
  String get productsChannelFixedFee;

  /// No description provided for @productsChannelShippingYouPay.
  ///
  /// In en, this message translates to:
  /// **'Shipping you pay'**
  String get productsChannelShippingYouPay;

  /// No description provided for @productsChannelPaidWhenPlaced.
  ///
  /// In en, this message translates to:
  /// **'Orders are paid when placed'**
  String get productsChannelPaidWhenPlaced;

  /// No description provided for @productsChannelPaidUpfront.
  ///
  /// In en, this message translates to:
  /// **'Like a marketplace that collects up front'**
  String get productsChannelPaidUpfront;

  /// No description provided for @productsChannelUnpaidStart.
  ///
  /// In en, this message translates to:
  /// **'New orders start unpaid, for cash on delivery or chat sales'**
  String get productsChannelUnpaidStart;

  /// No description provided for @productsChannelYouKeep.
  ///
  /// In en, this message translates to:
  /// **'On a {sale} sale you keep'**
  String productsChannelYouKeep(String sale);

  /// No description provided for @productsChannelBeforeMaterials.
  ///
  /// In en, this message translates to:
  /// **'before materials.'**
  String get productsChannelBeforeMaterials;

  /// No description provided for @productsChannelNoFees.
  ///
  /// In en, this message translates to:
  /// **'No fees'**
  String get productsChannelNoFees;

  /// No description provided for @productsChannelRecipeShipping.
  ///
  /// In en, this message translates to:
  /// **'{fees} · you pay {shipping} shipping'**
  String productsChannelRecipeShipping(String fees, String shipping);

  /// No description provided for @productsChannelHiddenKeep.
  ///
  /// In en, this message translates to:
  /// **'Hidden from new orders · on a {sale} sale you keep'**
  String productsChannelHiddenKeep(String sale);

  /// No description provided for @unitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Units of measure'**
  String get unitsTitle;

  /// No description provided for @unitsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No units yet'**
  String get unitsEmptyTitle;

  /// No description provided for @unitsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add what you count things in, like pc, sheet or kg.'**
  String get unitsEmptyMessage;

  /// No description provided for @unitsAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add unit'**
  String get unitsAddButton;

  /// No description provided for @unitsFab.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitsFab;

  /// No description provided for @unitsNew.
  ///
  /// In en, this message translates to:
  /// **'New unit'**
  String get unitsNew;

  /// No description provided for @unitsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {label}'**
  String unitsEditTitle(String label);

  /// No description provided for @unitsDefaultNote.
  ///
  /// In en, this message translates to:
  /// **'New items start on this'**
  String get unitsDefaultNote;

  /// No description provided for @unitsActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit unit'**
  String get unitsActionEdit;

  /// No description provided for @unitsActionUseForNew.
  ///
  /// In en, this message translates to:
  /// **'Use for new items'**
  String get unitsActionUseForNew;

  /// No description provided for @unitsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {label}?'**
  String unitsDeleteTitle(String label);

  /// No description provided for @unitsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Materials and products counted in it keep their numbers, so move them to another unit first.'**
  String get unitsDeleteMessage;

  /// No description provided for @unitsDefaultTag.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get unitsDefaultTag;

  /// No description provided for @unitsDragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get unitsDragToReorder;

  /// No description provided for @unitsFooter.
  ///
  /// In en, this message translates to:
  /// **'Everything you count is written with one of these: stock, what a product uses, what an order reserves. Long-press one to rename it, make it the default for new items, or delete it.'**
  String get unitsFooter;

  /// No description provided for @unitsPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every number for this is written with it.'**
  String get unitsPickerSubtitle;

  /// No description provided for @unitsPickerHelper.
  ///
  /// In en, this message translates to:
  /// **'Add more in More → Units of measure'**
  String get unitsPickerHelper;

  /// No description provided for @unitsFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitsFieldLabel;

  /// No description provided for @unitsFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. sheet, board, kg'**
  String get unitsFieldHint;

  /// No description provided for @unitsFieldHelper.
  ///
  /// In en, this message translates to:
  /// **'Shown exactly as you type it, so an abbreviation like kg or m stays correct.'**
  String get unitsFieldHelper;

  /// No description provided for @unitsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the unit a name'**
  String get unitsNameRequired;

  /// No description provided for @unitsTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep it under {max} characters — it shows next to every number'**
  String unitsTooLong(String max);

  /// No description provided for @discountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get discountsTitle;

  /// No description provided for @discountsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No discounts yet'**
  String get discountsEmptyTitle;

  /// No description provided for @discountsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Save the ones you give often, like 10% for regulars. You can still type any discount on an order.'**
  String get discountsEmptyMessage;

  /// No description provided for @discountsAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add discount'**
  String get discountsAddButton;

  /// No description provided for @discountsFab.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discountsFab;

  /// No description provided for @discountsNew.
  ///
  /// In en, this message translates to:
  /// **'New discount'**
  String get discountsNew;

  /// No description provided for @discountsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {label}'**
  String discountsEditTitle(String label);

  /// No description provided for @discountsActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit discount'**
  String get discountsActionEdit;

  /// No description provided for @discountsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {label}?'**
  String discountsDeleteTitle(String label);

  /// No description provided for @discountsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Orders that already have it keep it.'**
  String get discountsDeleteMessage;

  /// No description provided for @discountsDragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get discountsDragToReorder;

  /// No description provided for @discountsFooter.
  ///
  /// In en, this message translates to:
  /// **'These show as one-tap chips when you review an order. Orders keep their own copy, so editing one here never changes past orders.'**
  String get discountsFooter;

  /// No description provided for @discountsNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Loyal customer'**
  String get discountsNameHint;

  /// No description provided for @discountsKindPercent.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get discountsKindPercent;

  /// No description provided for @discountsKindFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount'**
  String get discountsKindFixed;

  /// No description provided for @discountsPercentOff.
  ///
  /// In en, this message translates to:
  /// **'Percent off'**
  String get discountsPercentOff;

  /// No description provided for @discountsAmountOff.
  ///
  /// In en, this message translates to:
  /// **'Amount off'**
  String get discountsAmountOff;

  /// No description provided for @discountsPercentHelper.
  ///
  /// In en, this message translates to:
  /// **'Taken off the items total'**
  String get discountsPercentHelper;

  /// No description provided for @discountsFixedHelper.
  ///
  /// In en, this message translates to:
  /// **'Taken off the order once'**
  String get discountsFixedHelper;

  /// No description provided for @discountsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the discount a name'**
  String get discountsNameRequired;

  /// No description provided for @discountsAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero'**
  String get discountsAmountRequired;

  /// No description provided for @discountsPercentMax.
  ///
  /// In en, this message translates to:
  /// **'A percentage can be at most 100'**
  String get discountsPercentMax;

  /// No description provided for @stockActionReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive stock'**
  String get stockActionReceive;

  /// No description provided for @stockActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit material'**
  String get stockActionEdit;

  /// No description provided for @stockActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete material'**
  String get stockActionDelete;

  /// No description provided for @stockArchivedSnack.
  ///
  /// In en, this message translates to:
  /// **'{name} archived'**
  String stockArchivedSnack(String name);

  /// No description provided for @stockUnarchivedSnack.
  ///
  /// In en, this message translates to:
  /// **'{name} is back in your lists'**
  String stockUnarchivedSnack(String name);

  /// No description provided for @stockDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String stockDeleteTitle(String name);

  /// No description provided for @stockDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This can’t be undone. Materials used in a product or an order can’t be deleted; archive them instead.'**
  String get stockDeleteBody;

  /// No description provided for @stockDeleteOnHand.
  ///
  /// In en, this message translates to:
  /// **'You still have {quantity} on hand. Its stock history goes too.'**
  String stockDeleteOnHand(String quantity);

  /// No description provided for @stockDeletedSnack.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String stockDeletedSnack(String name);

  /// No description provided for @stockFilterAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get stockFilterAny;

  /// No description provided for @stockFilterLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get stockFilterLow;

  /// No description provided for @stockFilterPromised.
  ///
  /// In en, this message translates to:
  /// **'Promised'**
  String get stockFilterPromised;

  /// No description provided for @stockFilterArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get stockFilterArchived;

  /// No description provided for @stockFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter materials'**
  String get stockFilterTitle;

  /// No description provided for @stockFilterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Works together with search.'**
  String get stockFilterSubtitle;

  /// No description provided for @stockFilterStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockFilterStock;

  /// No description provided for @stockFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get stockFilterClear;

  /// No description provided for @stockFilterShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get stockFilterShow;

  /// No description provided for @stockArchivedTag.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get stockArchivedTag;

  /// No description provided for @stockCardFree.
  ///
  /// In en, this message translates to:
  /// **'{quantity} free'**
  String stockCardFree(String quantity);

  /// No description provided for @stockCardPromised.
  ///
  /// In en, this message translates to:
  /// **'{quantity} promised'**
  String stockCardPromised(String quantity);

  /// No description provided for @stockCardReorderAt.
  ///
  /// In en, this message translates to:
  /// **'reorder at {quantity}'**
  String stockCardReorderAt(String quantity);

  /// No description provided for @stockCardShort.
  ///
  /// In en, this message translates to:
  /// **'{quantity} short'**
  String stockCardShort(String quantity);

  /// No description provided for @stockBuyListButton.
  ///
  /// In en, this message translates to:
  /// **'Buy list'**
  String get stockBuyListButton;

  /// No description provided for @stockBuyListButtonCount.
  ///
  /// In en, this message translates to:
  /// **'Buy list · {count}'**
  String stockBuyListButtonCount(int count);

  /// No description provided for @stockSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search materials'**
  String get stockSearchHint;

  /// No description provided for @stockEmptyNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No materials yet'**
  String get stockEmptyNoneTitle;

  /// No description provided for @stockEmptyNoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Add the beads, yarn and boxes your products are made from.'**
  String get stockEmptyNoneMessage;

  /// No description provided for @stockAddMaterial.
  ///
  /// In en, this message translates to:
  /// **'Add material'**
  String get stockAddMaterial;

  /// No description provided for @stockEmptyNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get stockEmptyNoMatchTitle;

  /// No description provided for @stockEmptyNoMatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches \"{query}\".'**
  String stockEmptyNoMatchMessage(String query);

  /// No description provided for @stockEmptyAllArchivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Every material is archived'**
  String get stockEmptyAllArchivedTitle;

  /// No description provided for @stockEmptyAllArchivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Filter by Archived to see them.'**
  String get stockEmptyAllArchivedMessage;

  /// No description provided for @stockEmptyNotLowTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing is low'**
  String get stockEmptyNotLowTitle;

  /// No description provided for @stockEmptyNotLowMessage.
  ///
  /// In en, this message translates to:
  /// **'Every material is above its reorder level.'**
  String get stockEmptyNotLowMessage;

  /// No description provided for @stockEmptyNoPromisedTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing promised'**
  String get stockEmptyNoPromisedTitle;

  /// No description provided for @stockEmptyNoPromisedMessage.
  ///
  /// In en, this message translates to:
  /// **'Materials reserved by open orders show up here.'**
  String get stockEmptyNoPromisedMessage;

  /// No description provided for @stockMaterialNotFound.
  ///
  /// In en, this message translates to:
  /// **'Material not found'**
  String get stockMaterialNotFound;

  /// No description provided for @stockReceiveCaption.
  ///
  /// In en, this message translates to:
  /// **'RECEIVE'**
  String get stockReceiveCaption;

  /// No description provided for @stockReceiveEnterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter what you paid per pack'**
  String get stockReceiveEnterPrice;

  /// No description provided for @stockReceiveAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {quantity} of {name}'**
  String stockReceiveAdded(String quantity, String name);

  /// No description provided for @stockReceivePacksCaption.
  ///
  /// In en, this message translates to:
  /// **'PACKS RECEIVED'**
  String get stockReceivePacksCaption;

  /// No description provided for @stockReceivePerPack.
  ///
  /// In en, this message translates to:
  /// **'{quantity} per pack'**
  String stockReceivePerPack(String quantity);

  /// No description provided for @stockReceivePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per pack'**
  String get stockReceivePriceLabel;

  /// No description provided for @stockSupplierOptional.
  ///
  /// In en, this message translates to:
  /// **'Supplier (optional)'**
  String get stockSupplierOptional;

  /// No description provided for @stockReceiveAfterCaption.
  ///
  /// In en, this message translates to:
  /// **'AFTER RECEIVING'**
  String get stockReceiveAfterCaption;

  /// No description provided for @stockReceiveUnitCost.
  ///
  /// In en, this message translates to:
  /// **'Unit cost (weighted)'**
  String get stockReceiveUnitCost;

  /// No description provided for @stockReceiveCostUp.
  ///
  /// In en, this message translates to:
  /// **'Products using this will cost a bit more to make.'**
  String get stockReceiveCostUp;

  /// No description provided for @stockReceiveAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add {quantity} to stock'**
  String stockReceiveAddButton(String quantity);

  /// No description provided for @stockPacks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} pack} other{{count} packs}}'**
  String stockPacks(int count);

  /// No description provided for @stockBuyListTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy list'**
  String get stockBuyListTitle;

  /// No description provided for @stockBuyListCopyHeader.
  ///
  /// In en, this message translates to:
  /// **'CraftBook buy list'**
  String get stockBuyListCopyHeader;

  /// No description provided for @stockBuyListCopyLine.
  ///
  /// In en, this message translates to:
  /// **'- {name}: {amount}, {cost}'**
  String stockBuyListCopyLine(String name, String amount, String cost);

  /// No description provided for @stockBuyListCopyTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}'**
  String stockBuyListCopyTotal(String total);

  /// No description provided for @stockBuyListCopied.
  ///
  /// In en, this message translates to:
  /// **'Buy list copied'**
  String get stockBuyListCopied;

  /// No description provided for @stockBuyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to buy'**
  String get stockBuyEmptyTitle;

  /// No description provided for @stockBuyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Everything is above its reorder level.'**
  String get stockBuyEmptyMessage;

  /// No description provided for @stockBuyItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} item} other{{count} items}}'**
  String stockBuyItemCount(int count);

  /// No description provided for @stockBuyCopyList.
  ///
  /// In en, this message translates to:
  /// **'Copy list'**
  String get stockBuyCopyList;

  /// No description provided for @stockBuyTagResell.
  ///
  /// In en, this message translates to:
  /// **'Resell'**
  String get stockBuyTagResell;

  /// No description provided for @stockBuyTagBlocking.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Blocking {count} order} other{Blocking {count} orders}}'**
  String stockBuyTagBlocking(int count);

  /// No description provided for @stockBuyTagOutOfFree.
  ///
  /// In en, this message translates to:
  /// **'Out of free stock'**
  String get stockBuyTagOutOfFree;

  /// No description provided for @stockBuyTagBelowReorder.
  ///
  /// In en, this message translates to:
  /// **'Below reorder'**
  String get stockBuyTagBelowReorder;

  /// No description provided for @stockBuyVerb.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get stockBuyVerb;

  /// No description provided for @stockBuyFreeNow.
  ///
  /// In en, this message translates to:
  /// **'{quantity} free now'**
  String stockBuyFreeNow(String quantity);

  /// No description provided for @stockBuyHoldsUp.
  ///
  /// In en, this message translates to:
  /// **'Holds up: {products}'**
  String stockBuyHoldsUp(String products);

  /// No description provided for @stockCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Count stock'**
  String get stockCountTitle;

  /// No description provided for @stockCountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the real amount on the shelf.'**
  String get stockCountSubtitle;

  /// No description provided for @stockCountMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches the app ({quantity})'**
  String stockCountMatches(String quantity);

  /// No description provided for @stockCountDiff.
  ///
  /// In en, this message translates to:
  /// **'{change} from {quantity} in the app'**
  String stockCountDiff(String change, String quantity);

  /// No description provided for @stockCountSave.
  ///
  /// In en, this message translates to:
  /// **'Save count'**
  String get stockCountSave;

  /// No description provided for @stockCountSet.
  ///
  /// In en, this message translates to:
  /// **'Stock set to {quantity}'**
  String stockCountSet(String quantity);

  /// No description provided for @stockOnHandCaption.
  ///
  /// In en, this message translates to:
  /// **'ON HAND'**
  String get stockOnHandCaption;

  /// No description provided for @stockUnitOnHandCaption.
  ///
  /// In en, this message translates to:
  /// **'{unit} ON HAND'**
  String stockUnitOnHandCaption(String unit);

  /// No description provided for @stockStatShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get stockStatShort;

  /// No description provided for @stockStatFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get stockStatFree;

  /// No description provided for @stockStatPromised.
  ///
  /// In en, this message translates to:
  /// **'Promised'**
  String get stockStatPromised;

  /// No description provided for @stockStatReorderAt.
  ///
  /// In en, this message translates to:
  /// **'Reorder at'**
  String get stockStatReorderAt;

  /// No description provided for @stockStatUnitCost.
  ///
  /// In en, this message translates to:
  /// **'Unit cost'**
  String get stockStatUnitCost;

  /// No description provided for @stockStatPack.
  ///
  /// In en, this message translates to:
  /// **'Pack'**
  String get stockStatPack;

  /// No description provided for @stockStatSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get stockStatSupplier;

  /// No description provided for @stockReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get stockReceive;

  /// No description provided for @stockCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get stockCount;

  /// No description provided for @stockUsedIn.
  ///
  /// In en, this message translates to:
  /// **'Used in · {count}'**
  String stockUsedIn(int count);

  /// No description provided for @stockUsedInEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not part of any product yet.'**
  String get stockUsedInEmpty;

  /// No description provided for @stockHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get stockHistory;

  /// No description provided for @stockHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No stock changes yet.'**
  String get stockHistoryEmpty;

  /// No description provided for @stockUsagePer.
  ///
  /// In en, this message translates to:
  /// **'{quantity} per {makes}'**
  String stockUsagePer(String quantity, String makes);

  /// No description provided for @stockUsageEach.
  ///
  /// In en, this message translates to:
  /// **'{quantity} each'**
  String stockUsageEach(String quantity);

  /// No description provided for @stockMoveReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned from deleted order'**
  String get stockMoveReturned;

  /// No description provided for @stockMoveReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get stockMoveReceived;

  /// No description provided for @stockMoveUsed.
  ///
  /// In en, this message translates to:
  /// **'Used in an order'**
  String get stockMoveUsed;

  /// No description provided for @stockMoveCounted.
  ///
  /// In en, this message translates to:
  /// **'Counted'**
  String get stockMoveCounted;

  /// No description provided for @stockMoveWaste.
  ///
  /// In en, this message translates to:
  /// **'Waste'**
  String get stockMoveWaste;

  /// No description provided for @stockNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New material'**
  String get stockNewTitle;

  /// No description provided for @stockNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Glass seed beads 2mm'**
  String get stockNameHint;

  /// No description provided for @stockNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get stockNameRequired;

  /// No description provided for @stockCountedIn.
  ///
  /// In en, this message translates to:
  /// **'Counted in'**
  String get stockCountedIn;

  /// No description provided for @stockSectionBuy.
  ///
  /// In en, this message translates to:
  /// **'How you buy it'**
  String get stockSectionBuy;

  /// No description provided for @stockPerPackLabel.
  ///
  /// In en, this message translates to:
  /// **'Per pack'**
  String get stockPerPackLabel;

  /// No description provided for @stockUnitPerPackLabel.
  ///
  /// In en, this message translates to:
  /// **'{unit} per pack'**
  String stockUnitPerPackLabel(String unit);

  /// No description provided for @stockPackPrice.
  ///
  /// In en, this message translates to:
  /// **'Pack price'**
  String get stockPackPrice;

  /// No description provided for @stockPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a price'**
  String get stockPriceRequired;

  /// No description provided for @stockCostPerUnit.
  ///
  /// In en, this message translates to:
  /// **'{cost} per {unit}'**
  String stockCostPerUnit(String cost, String unit);

  /// No description provided for @stockSectionStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockSectionStock;

  /// No description provided for @stockOnHandNow.
  ///
  /// In en, this message translates to:
  /// **'On hand now'**
  String get stockOnHandNow;

  /// No description provided for @stockUnitOnHandNow.
  ///
  /// In en, this message translates to:
  /// **'{unit} on hand now'**
  String stockUnitOnHandNow(String unit);

  /// No description provided for @stockReorderHelp.
  ///
  /// In en, this message translates to:
  /// **'You’ll see a warning and it goes on the buy list when stock drops to the reorder level.'**
  String get stockReorderHelp;

  /// No description provided for @stockNumberAboveZero.
  ///
  /// In en, this message translates to:
  /// **'Enter a number above 0'**
  String get stockNumberAboveZero;

  /// No description provided for @stockNumberZeroOrMore.
  ///
  /// In en, this message translates to:
  /// **'Enter 0 or more'**
  String get stockNumberZeroOrMore;

  /// No description provided for @stockSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get stockSaving;

  /// No description provided for @stockSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get stockSaveChanges;

  /// No description provided for @stockAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String stockAdded(String name);

  /// No description provided for @stockUpdated.
  ///
  /// In en, this message translates to:
  /// **'{name} updated'**
  String stockUpdated(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
