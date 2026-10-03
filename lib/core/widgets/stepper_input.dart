import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// Stepper input with +/- buttons and a text field for manual entry.
class StepperInput extends StatefulWidget {
  final num value;
  final num min;
  final num max;
  final num step;
  final int decimals;
  final ValueChanged<num> onChanged;
  final String? label;

  const StepperInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.step = 1,
    this.decimals = 0,
    this.label,
  });

  @override
  State<StepperInput> createState() => _StepperInputState();
}

class _StepperInputState extends State<StepperInput> {
  late TextEditingController _controller;
  final _focusNode = FocusNode();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _commitText(_controller.text);
      }
    });
  }

  @override
  void didUpdateWidget(covariant StepperInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && oldWidget.value != widget.value) {
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatValue(num v) {
    if (widget.decimals <= 0) return v.toInt().toString();
    return v.toStringAsFixed(widget.decimals);
  }

  void _commitText(String text) {
    final parsed = double.tryParse(text);
    if (parsed != null) {
      final clamped = parsed.clamp(
        widget.min.toDouble(),
        widget.max.toDouble(),
      );
      widget.onChanged(widget.decimals <= 0 ? clamped.toInt() : clamped);
    } else {
      _controller.text = _formatValue(widget.value);
    }
    setState(() => _isEditing = false);
  }

  void _unfocus() {
    _focusNode.unfocus();
    if (_isEditing) {
      _commitText(_controller.text);
    }
  }

  void _increment() {
    _unfocus();
    final next = widget.value + widget.step;
    if (next <= widget.max) {
      widget.onChanged(widget.decimals <= 0 ? next.toInt() : next);
    }
  }

  void _decrement() {
    _unfocus();
    final next = widget.value - widget.step;
    if (next >= widget.min) {
      widget.onChanged(widget.decimals <= 0 ? next.toInt() : next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.remove,
          onPressed: widget.value > widget.min ? _decrement : null,
        ),
        SizedBox(
          width: 48,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(widget.decimals > 0 ? r'[\d.]' : r'\d'),
              ),
            ],
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              isDense: true,
            ),
            onTap: () => setState(() => _isEditing = true),
            onChanged: (_) => setState(() => _isEditing = true),
            onSubmitted: _commitText,
            onEditingComplete: () => _commitText(_controller.text),
          ),
        ),
        _StepperButton(
          icon: Icons.add,
          onPressed: widget.value < widget.max ? _increment : null,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepperButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.paper,
            border: Border.all(color: AppColors.hair),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: onPressed != null ? AppColors.ink : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
