import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/palettes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../domain/entities/order_amount_shown.dart';
import '../../domain/entities/theme_settings.dart';
import '../bloc/order_amount_cubit.dart';
import '../bloc/theme_cubit.dart';

/// Colour scheme swatches, dark mode (Auto follows the phone, On/Off
/// force it) and which amount order cards show.
class AppearanceCard extends StatelessWidget {
  const AppearanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = getIt<ThemeCubit>();
    return AppCard(
      child: BlocBuilder<ThemeCubit, ThemeSettings>(
        bloc: cubit,
        builder: (context, look) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Colour scheme',
                style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                for (final p in AppPalette.values) ...[
                  if (p != AppPalette.values.first)
                    const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PaletteSwatch(
                      palette: p,
                      selected: p == look.palette,
                      onTap: () => cubit.setPalette(p),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Text('Dark mode',
                style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
            const SizedBox(height: 2),
            Text(
              look.mode == ThemeMode.system
                  ? 'Auto follows your phone'
                  : 'Overrides your phone setting',
              style: AppTextStyles.bodySmall.copyWith(color: c.muted),
            ),
            const SizedBox(height: AppSpacing.md),
            ChoiceChipRow<ThemeMode>.single(
              options: const [
                ChipOption(ThemeMode.system, 'Auto'),
                ChipOption(ThemeMode.dark, 'On'),
                ChipOption(ThemeMode.light, 'Off'),
              ],
              selected: look.mode,
              onSelected: cubit.setMode,
            ),
            const SizedBox(height: 20),
            const _OrderAmountSetting(),
          ],
        ),
      ),
    );
  }
}

class _OrderAmountSetting extends StatelessWidget {
  const _OrderAmountSetting();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = getIt<OrderAmountCubit>();
    return BlocBuilder<OrderAmountCubit, OrderAmountShown>(
      bloc: cubit,
      builder: (context, shown) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order cards show',
              style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
          const SizedBox(height: 2),
          Text(
            shown == OrderAmountShown.total
                ? 'What the customer pays'
                : 'What you keep after costs',
            style: AppTextStyles.bodySmall.copyWith(color: c.muted),
          ),
          const SizedBox(height: AppSpacing.md),
          ChoiceChipRow<OrderAmountShown>.single(
            options: const [
              ChipOption(OrderAmountShown.total, 'Total'),
              ChipOption(OrderAmountShown.profit, 'Profit'),
            ],
            selected: shown,
            onSelected: cubit.set,
          ),
        ],
      ),
    );
  }
}

/// A miniature of the app in [palette], in the brightness currently shown,
/// so the choice previews what it will look like.
class PaletteSwatch extends StatelessWidget {
  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  const PaletteSwatch({
    super.key,
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Another palette's colours on purpose: this is the preview.
    final p = palette.forBrightness(Theme.of(context).brightness);
    return Semantics(
      selected: selected,
      button: true,
      label: '${palette.label} colour scheme',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              height: 64,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: p.paper,
                borderRadius: AppRadii.controlAll,
                border: Border.all(
                  color: selected ? c.ink : c.hair,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: p.board,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 8,
                        decoration: BoxDecoration(
                          color: p.go,
                          borderRadius: AppRadii.pillAll,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: p.coin, shape: BoxShape.circle),
                      ),
                      const Spacer(),
                      if (selected)
                        Icon(Icons.check_rounded, size: 11, color: p.ink),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              palette.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? c.ink : c.muted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
