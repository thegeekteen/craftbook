import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_restarter.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/more_row.dart';
import '../../../../core/widgets/section_label.dart';
import '../bloc/debug_cubit.dart';
import '../bloc/debug_state.dart';

/// The Debug group on the More page: the fake-data tools.
///
/// Only ever mounted on a debug build — the More page puts `kDebugMode` in
/// front of it — so a shop owner's copy of the app has no way to empty its own
/// database.
class DebugSection extends StatelessWidget {
  const DebugSection({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<DebugCubit>(),
        child: const _DebugRows(),
      );
}

class _DebugRows extends StatelessWidget {
  const _DebugRows();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebugCubit, DebugState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Debug',
              padding: EdgeInsets.fromLTRB(2, 20, 2, 0)),
          const SizedBox(height: 8),
          AppCard.flush(
            child: CardList(children: [
              MoreRow(
                icon: Icons.category_outlined,
                title: 'Seed fake data',
                subtitle: state.phase == DebugPhase.seeding
                    ? 'Building the shop…'
                    : 'Replaces everything with a sample shop that covers '
                        'every screen. Long-press for another one.',
                onTap: () => _seed(context),
                onLongPress: () => _seedAnotherShop(context),
                trailing: state.phase == DebugPhase.seeding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : null,
              ),
              MoreRow(
                icon: Icons.delete_sweep_outlined,
                iconColor: context.colors.alert,
                title: 'Clear all data',
                subtitle: state.phase == DebugPhase.clearing
                    ? 'Clearing…'
                    : 'Leaves an empty shop, as new',
                onTap: () => _clear(context),
                trailing: state.phase == DebugPhase.clearing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : null,
              ),
              MoreRow(
                icon: Icons.storage_outlined,
                title: 'Database & coverage',
                subtitle: state.error ??
                    'Schema, row counts, and which options the data used',
                onTap: () => context.push(RouteNames.debugDatabase),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _seed(BuildContext context,
      {int? seed, bool skipConfirm = false}) async {
    final cubit = context.read<DebugCubit>();
    if (!skipConfirm) {
      final go = await ConfirmDialog.show(
        context,
        title: 'Replace everything with a sample shop?',
        message: 'Craftbook deletes every order, product and material on this '
            'phone, then writes a shop full of sample data. Export a backup '
            'first if this is a real shop.',
        confirmText: 'Seed it',
        isDestructive: true,
      );
      if (!go) return;
    }
    final result = await cubit.seed(seed: seed);
    if (!context.mounted) return;
    switch (result) {
      case Success(:final value):
        await _restart(
            context,
            'Seeded a sample shop · seed ${value.seed} · ${value.orders} '
            'orders, ${value.buyListLines} on the buy list');
      case Error(:final failure):
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  /// A typed seed is how you look at a second shop, or rebuild the one someone
  /// else is describing to you.
  Future<void> _seedAnotherShop(BuildContext context) async {
    // The field owns its own controller (see [_SeedField]); the text is
    // captured through [onChanged] because the controller is gone by the time
    // the dialog finishes closing.
    var typed = '';
    final go = await ConfirmDialog.show(
      context,
      title: 'Another shop',
      message: 'The same seed always builds the same shop, so this is how you '
          'reproduce one you have already seen. Leave it empty for the '
          'standard shop.',
      confirmText: 'Seed it',
      isDestructive: true,
      content: _SeedField(onChanged: (value) => typed = value),
    );
    if (!context.mounted || !go) return;
    typed = typed.trim();
    // A typo would otherwise be read as "no seed" and replace the shop with the
    // standard one, which is not what was asked for. Nothing is written here.
    final seed = typed.isEmpty ? null : int.tryParse(typed);
    if (typed.isNotEmpty && seed == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('"$typed" is not a whole number, so nothing seeded.')));
      return;
    }
    // This dialog was the confirmation, so seeding doesn't ask twice.
    await _seed(context, seed: seed, skipConfirm: true);
  }

  Future<void> _clear(BuildContext context) async {
    final cubit = context.read<DebugCubit>();
    final go = await ConfirmDialog.show(
      context,
      title: 'Delete everything?',
      message: 'Every order, product, material and note goes, and the '
          'settings go back to their defaults. There is no undo — export a '
          'backup first if you might want this data back.',
      confirmText: 'Delete everything',
      isDestructive: true,
    );
    if (!go) return;
    final result = await cubit.clear();
    if (!context.mounted) return;
    switch (result) {
      case Success():
        await _restart(context, 'Cleared. The shop is empty again');
      case Error(:final failure):
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  /// A seed or a clear changes every screen at once, so the app is rebuilt from
  /// the top rather than patched screen by screen.
  Future<void> _restart(BuildContext context, String message) async {
    final restarter = AppRestarter.maybeOf(context);
    if (restarter != null) {
      await restarter.restart(message: message);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$message. Restart the app to see it.')));
  }
}

/// The seed box inside the "Another shop" dialog.
///
/// It owns its [TextEditingController] and disposes it in [dispose], which
/// Flutter runs only once the dialog route has fully closed. Handing a caller's
/// controller to [ConfirmDialog] instead means the field rebuilds during the
/// closing transition against a controller the caller already disposed, which
/// throws and aborts the seed.
class _SeedField extends StatefulWidget {
  const _SeedField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<_SeedField> createState() => _SeedFieldState();
}

class _SeedFieldState extends State<_SeedField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        onChanged: widget.onChanged,
        decoration: const InputDecoration(
          labelText: 'Seed',
          hintText: 'empty for the standard shop',
        ),
      );
}
