import 'package:flutter/material.dart';

import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../domain/usecases/unit_usecases.dart';

/// Asks for a unit's label and returns it trimmed, or null when dismissed.
///
/// A unit is one short word or abbreviation that sits next to every number in
/// the app, so there is nothing else to fill in.
Future<String?> showUnitSheet(
  BuildContext context, {
  required String title,
  String? initial,
  String actionLabel = 'Save',
}) {
  return showAppSheet<String>(
    context: context,
    title: title,
    builder: (_) => UnitForm(initial: initial, actionLabel: actionLabel),
  );
}

/// The body of [showUnitSheet]; public so it can be tested alone.
class UnitForm extends StatefulWidget {
  final String? initial;
  final String actionLabel;

  const UnitForm({super.key, this.initial, this.actionLabel = 'Save'});

  @override
  State<UnitForm> createState() => _UnitFormState();
}

class _UnitFormState extends State<UnitForm> {
  late final _label = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  void _save() {
    final label = _label.text.trim();
    if (label.isEmpty) {
      setState(() => _error = context.l10n.unitsNameRequired);
      return;
    }
    if (label.length > maxUnitLabelLength) {
      setState(() =>
          _error = context.l10n.unitsTooLong(maxUnitLabelLength.toString()));
      return;
    }
    Navigator.pop(context, label);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _label,
          autofocus: true,
          maxLength: maxUnitLabelLength,
          decoration: InputDecoration(
            labelText: context.l10n.unitsFieldLabel,
            hintText: context.l10n.unitsFieldHint,
            helperText: context.l10n.unitsFieldHelper,
          ),
          onSubmitted: (_) => _save(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!,
              style: AppTextStyles.bodySmall.copyWith(color: c.alert)),
        ],
        const SizedBox(height: 16),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton(
            onPressed: _save,
            child: Text(widget.actionLabel),
          ),
        ),
      ],
    );
  }
}
