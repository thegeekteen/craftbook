import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/app_update.dart';
import '../bloc/update_cubit.dart';
import '../bloc/update_state.dart';

/// "Check for updates" on the More page. Needs an [UpdateCubit] above it.
class UpdateRow extends StatelessWidget {
  const UpdateRow({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return BlocConsumer<UpdateCubit, UpdateState>(
      listenWhen: (prev, next) =>
          prev.status == UpdateStatus.checking &&
          next.status == UpdateStatus.available,
      listener: (context, state) => _offer(context, state.update!),
      builder: (context, state) {
        final cubit = context.read<UpdateCubit>();
        final update = state.update;
        final (String title, String subtitle, VoidCallback? onTap) =
            switch (state.status) {
          UpdateStatus.idle => (
              'Check for updates',
              'Get the newest version of Craftbook',
              cubit.check,
            ),
          UpdateStatus.checking => ('Check for updates', 'Checking…', null),
          UpdateStatus.upToDate => (
              'Check for updates',
              "You're on the newest version",
              cubit.check,
            ),
          UpdateStatus.available => (
              'Update to ${update!.version}',
              'Tap to download and install',
              () => _offer(context, update),
            ),
          UpdateStatus.downloading => (
              'Update to ${update!.version}',
              state.progress == null
                  ? 'Downloading…'
                  : 'Downloading… ${(state.progress! * 100).round()}%',
              null,
            ),
          UpdateStatus.failed => (
              update == null
                  ? 'Check for updates'
                  : 'Update to ${update.version}',
              state.error ?? 'Something went wrong. Tap to try again.',
              update == null ? cubit.check : cubit.install,
            ),
        };
        final busy = state.status == UpdateStatus.checking ||
            state.status == UpdateStatus.downloading;
        final highlight = state.status == UpdateStatus.available;
        return CardRow(
          onTap: onTap,
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: highlight ? c.goSoft : c.paper,
              borderRadius: AppRadii.controlAll,
            ),
            child: Icon(Icons.system_update_rounded,
                size: 20, color: highlight ? c.go : c.ink),
          ),
          title: Text(title),
          subtitle: Text(
            subtitle,
            style: state.status == UpdateStatus.failed
                ? TextStyle(color: c.alert)
                : null,
          ),
          trailing: busy
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    value: state.progress,
                    color: c.go,
                  ),
                )
              : Icon(Icons.chevron_right_rounded, color: c.muted),
        );
      },
    );
  }

  Future<void> _offer(BuildContext context, AppUpdate update) async {
    final cubit = context.read<UpdateCubit>();
    final c = context.colors;
    final notes = update.notes.trim();
    final go = await ConfirmDialog.show(
      context,
      title: 'Update to ${update.version}',
      message: 'Your orders, stock and notes stay as they are.',
      confirmText: 'Update',
      cancelText: 'Later',
      content: notes.isEmpty
          ? null
          : ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: SingleChildScrollView(
                child: MarkdownBody(
                  data: notes,
                  styleSheet: MarkdownStyleSheet(
                    p: AppTextStyles.bodySmall.copyWith(color: c.muted),
                    listBullet:
                        AppTextStyles.bodySmall.copyWith(color: c.muted),
                    h2: AppTextStyles.bodyLarge.copyWith(color: c.ink),
                    a: AppTextStyles.bodySmall.copyWith(color: c.go),
                  ),
                ),
              ),
            ),
    );
    if (go) cubit.install();
  }
}
