import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../domain/entities/app_language.dart';

/// Picks the app's language. Returns null when dismissed.
Future<AppLanguage?> showLanguageSheet(
  BuildContext context, {
  required AppLanguage current,
}) {
  return showAppSheet<AppLanguage>(
    context: context,
    title: context.l10n.languageTitle,
    subtitle: context.l10n.languageSubtitle,
    builder: (_) => LanguagePicker(current: current),
  );
}

extension AppLanguageLabel on AppLanguage {
  /// Languages are named in their own tongue wherever they are listed, so a
  /// reader who ended up in the wrong one can still find theirs.
  String label(BuildContext context) => switch (this) {
        AppLanguage.system => context.l10n.languageSystem,
        AppLanguage.en => context.l10n.languageEnglish,
        AppLanguage.fil => context.l10n.languageFilipino,
      };
}

/// The body of [showLanguageSheet]; public so it can be tested alone.
class LanguagePicker extends StatelessWidget {
  final AppLanguage current;

  const LanguagePicker({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final language in AppLanguage.values)
          InkWell(
            borderRadius: AppRadii.controlAll,
            onTap: () => Navigator.pop(context, language),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(language.label(context),
                        style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
                  ),
                  if (language == current)
                    Icon(Icons.check_rounded, size: 20, color: c.go),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
