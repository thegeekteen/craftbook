import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';

/// Renders the bundled README so the in-app help is the repo's own docs.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  /// Declared as an asset in pubspec.yaml.
  static const readmeAsset = 'README.md';

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  Future<String>? _readme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // DefaultAssetBundle (not rootBundle) so tests can supply their own.
    _readme ??= DefaultAssetBundle.of(context).loadString(AboutPage.readmeAsset);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: FutureBuilder<String>(
        future: _readme,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: AppSpacing.page,
                child: Text(
                  "Couldn't load the guide. Please try again.",
                  style: AppTextStyles.bodyMedium.copyWith(color: c.muted),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Markdown(
            data: snapshot.requireData,
            padding: AppSpacing.page,
            styleSheet: _styleSheet(c),
          );
        },
      ),
    );
  }

  MarkdownStyleSheet _styleSheet(CraftColors c) {
    final body = AppTextStyles.bodyMedium.copyWith(color: c.ink);
    TextStyle heading(TextStyle base) => base.copyWith(color: c.ink);
    final hairline = BorderSide(color: c.hair);
    return MarkdownStyleSheet(
      p: body,
      a: body.copyWith(color: c.go, decoration: TextDecoration.underline),
      strong: body.copyWith(fontWeight: FontWeight.w700),
      em: body.copyWith(fontStyle: FontStyle.italic),
      h1: heading(AppTextStyles.displayMedium),
      h2: heading(AppTextStyles.displaySmall),
      h3: heading(AppTextStyles.bodyLarge.copyWith(fontSize: 17)),
      h4: heading(AppTextStyles.bodyLarge),
      h5: heading(AppTextStyles.bodyLarge),
      h6: heading(AppTextStyles.bodyLarge),
      listBullet: body,
      blockquote: body.copyWith(color: c.muted),
      blockquoteDecoration: BoxDecoration(
        color: c.paper,
        borderRadius: AppRadii.controlAll,
        border: Border(left: BorderSide(color: c.hair, width: 3)),
      ),
      code: AppTextStyles.bodySmall.copyWith(
        fontFamily: AppTextStyles.mono,
        color: c.ink,
        backgroundColor: c.paper,
      ),
      codeblockPadding: const EdgeInsets.all(12),
      codeblockDecoration: BoxDecoration(
        color: c.paper,
        borderRadius: AppRadii.controlAll,
        border: Border.fromBorderSide(hairline),
      ),
      horizontalRuleDecoration: BoxDecoration(border: Border(top: hairline)),
      tableHead: body.copyWith(fontWeight: FontWeight.w700),
      tableBody: AppTextStyles.bodySmall.copyWith(color: c.ink),
      tableBorder: TableBorder.all(color: c.hair),
      tableCellsPadding: const EdgeInsets.all(8),
    );
  }
}
