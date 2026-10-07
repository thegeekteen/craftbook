import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/link_launcher.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/action_sheet.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_label.dart';
import '../../domain/entities/social_link.dart';
import '../../domain/entities/social_platform.dart';
import '../../domain/social_url.dart';
import '../bloc/social_links_bloc.dart';
import '../bloc/social_links_event.dart';
import '../bloc/social_links_state.dart';
import '../widgets/social_link_tile.dart';
import '../widgets/social_mark.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../l10n/gen/app_localizations.dart';

/// Shortcuts to the shop's pages on Facebook, TikTok, Shopee and the like.
class SocialLinksPage extends StatelessWidget {
  const SocialLinksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SocialLinksBloc>()..add(const LoadSocialLinks()),
      child: const _SocialLinksView(),
    );
  }
}

class _SocialLinksView extends StatefulWidget {
  const _SocialLinksView();

  @override
  State<_SocialLinksView> createState() => _SocialLinksViewState();
}

class _SocialLinksViewState extends State<_SocialLinksView> {
  bool _editing = false;

  Future<void> _open(SocialLink link) async {
    final opened = await getIt<LinkLauncher>().open(link.url);
    if (!opened && mounted) {
      context.showSnackBar(
        context.l10n.socialCouldntOpen(link.label),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<SocialLinksBloc>();
    return BlocConsumer<SocialLinksBloc, SocialLinksState>(
      listenWhen: (prev, s) =>
          s is SocialLinksError ||
          (s is SocialLinksLoaded &&
              s.hasNotice &&
              (prev is! SocialLinksLoaded || prev.serial != s.serial)),
      listener: (context, state) {
        if (state is SocialLinksError) {
          context.showSnackBar(state.message, isError: true);
        }
        if (state is SocialLinksLoaded) {
          context.showSnackBar(socialNotice(l10n, state),
              isError: state.isError);
        }
      },
      builder: (context, state) {
        final links =
            state is SocialLinksLoaded ? state.links : const <SocialLink>[];
        // Nothing left to edit once the list is empty.
        final editing = _editing && links.isNotEmpty;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.socialTitle),
            actions: [
              if (links.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _editing = !editing),
                  child: Text(editing ? l10n.commonDone : l10n.commonEdit),
                ),
            ],
          ),
          body: switch (state) {
            SocialLinksError() => Center(
                child: ErrorState(
                  message: state.message,
                  onRetry: () => bloc.add(const LoadSocialLinks()),
                ),
              ),
            SocialLinksLoaded(links: final l) when l.isEmpty => Center(
                child: EmptyState(
                  icon: Icons.share_outlined,
                  title: l10n.socialEmptyTitle,
                  message: l10n.socialEmptyMessage,
                  actionLabel: l10n.socialAddShortcut,
                  onAction: () => _SocialLinkSheet.open(context, bloc),
                ),
              ),
            SocialLinksLoaded() => editing
                ? _EditList(links: links, bloc: bloc, onOpen: _open)
                : _Grid(links: links, bloc: bloc, onOpen: _open),
            _ => const Center(child: CircularProgressIndicator()),
          },
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _SocialLinkSheet.open(context, bloc),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.socialFab),
          ),
        );
      },
    );
  }
}

/// The snackbar text for the last action in [state].
String socialNotice(AppLocalizations l10n, SocialLinksLoaded state) {
  final name = state.subject ?? l10n.socialFallbackName;
  return switch (state.outcome) {
    SocialOutcome.added => l10n.socialOutcomeAdded(name),
    SocialOutcome.saved => l10n.socialOutcomeSaved(name),
    SocialOutcome.removed => l10n.socialOutcomeRemoved(name),
    null => state.message ?? '',
  };
}

enum _LinkAction { open, edit, remove }

/// The long-press menu on a shortcut, in the grid and in edit mode.
Future<void> _linkActions(BuildContext context, SocialLinksBloc bloc,
    SocialLink link, ValueChanged<SocialLink> onOpen) async {
  final l10n = context.l10n;
  final action = await showActionSheet<_LinkAction>(
    context,
    title: link.label,
    subtitle: link.displayUrl,
    actions: [
      SheetAction(
          value: _LinkAction.open,
          icon: Icons.open_in_new_rounded,
          label: l10n.socialOpen),
      SheetAction(
          value: _LinkAction.edit,
          icon: Icons.edit_outlined,
          label: l10n.socialEditShortcut),
      SheetAction(
          value: _LinkAction.remove,
          icon: Icons.delete_outline_rounded,
          label: l10n.commonRemove,
          destructive: true),
    ],
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case _LinkAction.open:
      onOpen(link);
    case _LinkAction.edit:
      await _SocialLinkSheet.open(context, bloc, link: link);
    case _LinkAction.remove:
      if (await _confirmRemove(context, link)) {
        bloc.add(DeleteSocialLinkEvent(link.id!));
      }
  }
}

Future<bool> _confirmRemove(BuildContext context, SocialLink link) {
  final l10n = context.l10n;
  return ConfirmDialog.show(
    context,
    title: l10n.socialRemoveTitle(link.label),
    message: l10n.socialRemoveMessage,
    confirmText: l10n.commonRemove,
    isDestructive: true,
  );
}

class _Grid extends StatelessWidget {
  final List<SocialLink> links;
  final SocialLinksBloc bloc;
  final ValueChanged<SocialLink> onOpen;

  const _Grid({required this.links, required this.bloc, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.xs,
            AppSpacing.gutter,
            0,
          ),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              mainAxisExtent: 140,
            ),
            itemCount: links.length,
            itemBuilder: (context, i) => SocialLinkTile(
              link: links[i],
              onTap: () => onOpen(links[i]),
              onLongPress: () => _linkActions(context, bloc, links[i], onOpen),
            ),
          ),
        ),
        SliverPadding(
          padding:
              const EdgeInsets.fromLTRB(20, 16, 20, AppSpacing.fabClearance),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.socialHint,
              style: AppTextStyles.bodySmall.copyWith(color: c.muted),
            ),
          ),
        ),
      ],
    );
  }
}

/// Edit mode: a list that can be dragged into a new order.
class _EditList extends StatelessWidget {
  final List<SocialLink> links;
  final SocialLinksBloc bloc;
  final ValueChanged<SocialLink> onOpen;

  const _EditList(
      {required this.links, required this.bloc, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.xs,
            AppSpacing.gutter,
            AppSpacing.fabClearance,
          ),
          sliver: SliverReorderableList(
            itemCount: links.length,
            onReorderItem: (from, to) =>
                bloc.add(ReorderSocialLinksEvent(from, to)),
            proxyDecorator: (child, _, __) => Material(
              color: Colors.transparent,
              elevation: 4,
              borderRadius: AppRadii.cardAll,
              child: child,
            ),
            itemBuilder: (context, i) {
              final link = links[i];
              return Padding(
                key: ValueKey(link.id),
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  onTap: () => _SocialLinkSheet.open(context, bloc, link: link),
                  onLongPress: () => _linkActions(context, bloc, link, onOpen),
                  padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                  child: Row(
                    children: [
                      SocialMark(
                          color: link.tileColor, glyph: link.glyph, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              link.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: c.ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              link.displayUrl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: c.muted),
                            ),
                          ],
                        ),
                      ),
                      ReorderableDragStartListener(
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            size: 20,
                            color: c.muted,
                            semanticLabel: l10n.socialDragReorder,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Add/edit form in a bottom sheet.
class _SocialLinkSheet extends StatefulWidget {
  final SocialLink? link;
  final SocialLinksBloc bloc;

  const _SocialLinkSheet({this.link, required this.bloc});

  static Future<void> open(BuildContext context, SocialLinksBloc bloc,
      {SocialLink? link}) {
    return showAppSheet(
      context: context,
      title: link == null
          ? context.l10n.socialNewShortcut
          : context.l10n.socialEditNamed(link.label),
      builder: (_) => _SocialLinkSheet(link: link, bloc: bloc),
    );
  }

  @override
  State<_SocialLinkSheet> createState() => _SocialLinkSheetState();
}

class _SocialLinkSheetState extends State<_SocialLinkSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _label = TextEditingController(
    text: widget.link?.preset == null ? widget.link?.label ?? '' : '',
  );
  late final _url = TextEditingController(text: widget.link?.url ?? '');
  late String _platform = widget.link?.platform ?? SocialPlatform.facebook.key;
  late int _color =
      widget.link?.colorValue ?? SocialPlatform.customColors.first;

  bool get _isCustom => _platform == SocialPlatform.customKey;

  @override
  void initState() {
    super.initState();
    // The preview follows what is typed.
    _label.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _label.dispose();
    _url.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.bloc.add(SaveSocialLinkEvent(
      id: widget.link?.id,
      platform: _platform,
      label: _isCustom ? _label.text : '',
      url: _url.text,
      colorValue: _isCustom ? _color : null,
    ));
    Navigator.pop(context);
  }

  Future<void> _remove() async {
    final link = widget.link!;
    if (await _confirmRemove(context, link) && mounted) {
      widget.bloc.add(DeleteSocialLinkEvent(link.id!));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final preset = SocialPlatform.byKey(_platform);
    final name = _label.text.trim();
    final previewColor = preset?.color ?? _color;
    final previewGlyph = preset?.glyph ??
        (name.isEmpty ? '?' : name.substring(0, 1).toUpperCase());

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
              child: SocialMark(
                  color: previewColor, glyph: previewGlyph, size: 64)),
          const SizedBox(height: 16),
          SectionLabel(l10n.socialSite),
          const SizedBox(height: 8),
          ChoiceChipRow<String>.single(
            wrap: true,
            selected: _platform,
            onSelected: (p) => setState(() => _platform = p),
            options: [
              for (final p in SocialPlatform.presets) ChipOption(p.key, p.name),
              ChipOption(SocialPlatform.customKey, l10n.socialOther),
            ],
          ),
          const SizedBox(height: 12),
          if (_isCustom) ...[
            TextFormField(
              controller: _label,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.commonName,
                hintText: l10n.socialNameHint,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.socialNameRequired
                  : null,
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _url,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: l10n.socialLinkLabel,
              hintText: preset?.urlHint ?? 'yourshop.com',
            ),
            validator: (v) => normalizeSocialUrl(v ?? '') == null
                ? l10n.socialLinkInvalid(preset?.urlHint ?? 'yourshop.com')
                : null,
          ),
          if (_isCustom) ...[
            const SizedBox(height: 16),
            SectionLabel(l10n.socialColour),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final swatch in SocialPlatform.customColors)
                  _Swatch(
                    color: swatch,
                    selected: swatch == _color,
                    onTap: () => setState(() => _color = swatch),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              if (widget.link != null)
                TextButton(
                  onPressed: _remove,
                  style: TextButton.styleFrom(foregroundColor: c.alert),
                  child: Text(l10n.commonRemove),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _save,
                child: Text(widget.link == null
                    ? l10n.socialAddShortcut
                    : l10n.commonSave),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final int color;
  final bool selected;
  final VoidCallback onTap;

  const _Swatch(
      {required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fill = Color(color);
    return Semantics(
      button: true,
      selected: selected,
      label: context.l10n.socialColour,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(
                color: selected ? c.ink : c.hair, width: selected ? 2.5 : 1),
          ),
          child: selected
              ? Icon(Icons.check_rounded,
                  size: 20, color: SocialMark.foregroundFor(fill))
              : null,
        ),
      ),
    );
  }
}
