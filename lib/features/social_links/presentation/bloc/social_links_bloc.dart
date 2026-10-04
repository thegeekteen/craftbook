import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/social_platform.dart';
import '../../domain/usecases/delete_social_link.dart';
import '../../domain/usecases/get_social_links.dart';
import '../../domain/usecases/reorder_social_links.dart';
import '../../domain/usecases/save_social_link.dart';
import 'social_links_event.dart';
import 'social_links_state.dart';

/// The shop's social shortcuts.
class SocialLinksBloc extends Bloc<SocialLinksEvent, SocialLinksState> {
  final GetSocialLinks getSocialLinks;
  final SaveSocialLink saveSocialLink;
  final DeleteSocialLink deleteSocialLink;
  final ReorderSocialLinks reorderSocialLinks;

  int _serial = 0;

  SocialLinksBloc({
    required this.getSocialLinks,
    required this.saveSocialLink,
    required this.deleteSocialLink,
    required this.reorderSocialLinks,
  }) : super(SocialLinksInitial()) {
    on<LoadSocialLinks>(_onLoad);
    on<SaveSocialLinkEvent>(_onSave);
    on<DeleteSocialLinkEvent>(_onDelete);
    on<ReorderSocialLinksEvent>(_onReorder);
  }

  Future<void> _onLoad(
    LoadSocialLinks event,
    Emitter<SocialLinksState> emit,
  ) async {
    if (state is! SocialLinksLoaded) emit(SocialLinksLoading());
    final result = await getSocialLinks();
    switch (result) {
      case Error(:final failure):
        emit(SocialLinksError(failure.message));
      case Success(:final value):
        emit(SocialLinksLoaded(links: value));
    }
  }

  Future<void> _onSave(
    SaveSocialLinkEvent event,
    Emitter<SocialLinksState> emit,
  ) async {
    final result = await saveSocialLink(
      id: event.id,
      platform: event.platform,
      label: event.label,
      url: event.url,
      colorValue: event.colorValue,
    );
    final name = event.label.trim().isNotEmpty
        ? event.label.trim()
        : SocialPlatform.byKey(event.platform)?.name ?? 'Shortcut';
    await _finish(
        emit, result, event.id == null ? '$name added' : '$name saved');
  }

  Future<void> _onDelete(
    DeleteSocialLinkEvent event,
    Emitter<SocialLinksState> emit,
  ) async {
    final current = state;
    final name = current is SocialLinksLoaded
        ? current.links.where((l) => l.id == event.id).firstOrNull?.label
        : null;
    final result = await deleteSocialLink(event.id);
    await _finish(emit, result, '${name ?? 'Shortcut'} removed');
  }

  Future<void> _onReorder(
    ReorderSocialLinksEvent event,
    Emitter<SocialLinksState> emit,
  ) async {
    final current = state;
    if (current is! SocialLinksLoaded) return;
    final links = [...current.links];
    links.insert(event.newIndex, links.removeAt(event.oldIndex));

    // Moves at once; a failed save puts the list back.
    emit(SocialLinksLoaded(links: links));
    final result = await reorderSocialLinks([for (final l in links) l.id!]);
    if (result case Error(:final failure)) {
      emit(current.withMessage(failure.message, ++_serial, isError: true));
    }
  }

  /// Reloads after a successful action and reports how it went.
  Future<void> _finish(
    Emitter<SocialLinksState> emit,
    Result<Object?> result,
    String successMessage,
  ) async {
    switch (result) {
      case Error(:final failure):
        final current = state;
        if (current is SocialLinksLoaded) {
          emit(current.withMessage(failure.message, ++_serial, isError: true));
        } else {
          emit(SocialLinksError(failure.message));
        }
      case Success():
        final loaded = await getSocialLinks();
        switch (loaded) {
          case Error(:final failure):
            emit(SocialLinksError(failure.message));
          case Success(:final value):
            emit(SocialLinksLoaded(links: value)
                .withMessage(successMessage, ++_serial));
        }
    }
  }
}
