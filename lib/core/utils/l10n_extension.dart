import 'package:flutter/widgets.dart';

import '../../l10n/gen/app_localizations.dart';

extension L10nContext on BuildContext {
  /// The app's translated strings: `context.l10n.ordersTitle`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
