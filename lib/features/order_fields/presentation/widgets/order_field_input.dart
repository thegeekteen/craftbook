import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/choice_chip_row.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/section_label.dart';
import '../../domain/entities/order_field.dart';
import '../../domain/order_field_codec.dart';
import '../../../../core/utils/l10n_extension.dart';

/// The order form input for one custom field. [value] and [onChanged] use
/// the stored encoding (see [OrderFieldCodec]); an empty string means unset.
class OrderFieldInput extends StatefulWidget {
  final OrderField field;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const OrderFieldInput({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<OrderFieldInput> createState() => _OrderFieldInputState();
}

class _OrderFieldInputState extends State<OrderFieldInput> {
  // Seeded once: the text then belongs to the user, since a number's stored
  // form can differ from what was typed ("1.50" is stored as "1.5").
  late final _controller = TextEditingController(text: widget.value ?? '');

  void _emit(String value) => widget.onChanged(value);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    final value = widget.value ?? '';
    return switch (field.type) {
      OrderFieldType.text => TextFormField(
          controller: _controller,
          enabled: widget.enabled,
          textCapitalization: TextCapitalization.sentences,
          minLines: 1,
          maxLines: field.isMultiline ? 4 : 1,
          keyboardType:
              field.isMultiline ? TextInputType.multiline : TextInputType.text,
          textInputAction: field.isMultiline
              ? TextInputAction.newline
              : TextInputAction.next,
          decoration: InputDecoration(labelText: field.name),
          onChanged: (v) => _emit(v.trim()),
        ),
      OrderFieldType.number => TextFormField(
          controller: _controller,
          enabled: widget.enabled,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
          ],
          decoration: InputDecoration(labelText: field.name),
          validator: (v) {
            final text = v?.trim() ?? '';
            if (text.isEmpty || OrderFieldCodec.encodeNumber(text) != null) {
              return null;
            }
            return context.l10n.orderFieldsEnterNumber;
          },
          onChanged: (v) {
            final text = v.trim();
            _emit(
                text.isEmpty ? '' : OrderFieldCodec.encodeNumber(text) ?? text);
          },
        ),
      OrderFieldType.date => DateField(
          label: field.name,
          value: OrderFieldCodec.decodeDate(value),
          onChanged: (d) => _emit(OrderFieldCodec.encodeDate(d)),
          onCleared: widget.enabled ? () => _emit('') : null,
        ),
      OrderFieldType.choice => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(field.name),
            const SizedBox(height: 8),
            ChoiceChipRow<String>(
              wrap: true,
              options: [
                for (final o in field.options) ChipOption(o, o),
                // A value whose option was renamed or removed since; shown
                // so saving the order doesn't silently drop it.
                if (value.isNotEmpty && !field.options.contains(value))
                  ChipOption(value, value),
              ],
              isSelected: (o) => o == value,
              // Tapping the picked choice again clears the field.
              onTap: (o) => _emit(o == value ? '' : o),
            ),
          ],
        ),
    };
  }
}
