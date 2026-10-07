import '../../../l10n/gen/app_localizations.dart';
import '../domain/entities/order_field.dart';

/// The translated name of a field type. The enum keeps its English label for
/// code that has no [AppLocalizations] to hand.
extension OrderFieldTypeLabel on OrderFieldType {
  String localized(AppLocalizations l10n) => switch (this) {
        OrderFieldType.text => l10n.orderFieldsTypeText,
        OrderFieldType.number => l10n.orderFieldsTypeNumber,
        OrderFieldType.date => l10n.orderFieldsTypeDate,
        OrderFieldType.choice => l10n.orderFieldsTypeChoice,
      };
}
