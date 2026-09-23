import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_note/features/create/domain/entities/post.dart';
import 'package:offline_note/features/create/domain/repos/local_post_repository.dart';
import 'package:offline_note/features/create/presentation/cubits/draft_state.dart';

const String localUserId = 'local-user';

class DraftCubit extends Cubit<DraftState> {
  final LocalPostRepository localPostRepository;

  int _generation = 0;
  StreamSubscription<List<Post>>? _draftStreamSubscription;

  DraftCubit({required this.localPostRepository}) : super(DraftInitial());

  void startDraftsStream() {
    final generation = ++_generation;
    _draftStreamSubscription?.cancel();

    _draftStreamSubscription = localPostRepository
        .watchDrafts(localUserId)
        .listen(
          (drafts) {
            if (generation != _generation) return;
            emit(DraftsLoaded(drafts));
          },
          onError: (error) {
            if (generation != _generation) return;
            emit(DraftError("Drafts stream error: $error"));
          },
        );
  }

  Future<void> saveDraft(Post draft) async {
    try {
      emit(DraftSaving());

      final now = DateTime.now();

      final localDraft = draft.copyWith(
        updatedAt: now,
        draftDate: draft.draftDate ?? now,
        isDraft: true,
        // syncState: LocalSyncState.localOnly.name,
        // pendingAction: PendingAction.none.name,
        // lastSyncError: null,
        isDeleted: false,
      );

      await localPostRepository.upsertPost(localDraft);

      emit(DraftSaved(localDraft));
    } catch (e) {
      emit(DraftError("Failed to save draft: $e"));
    }
  }

  Future<void> deleteDraft(String draftId) async {
    try {
      final draft = await localPostRepository.getPostById(draftId);

      if (draft == null) {
        emit(DraftError("Draft not found."));
        return;
      }

      await localPostRepository.hardDeleteDraftWithLocalImage(draftId);
      emit(DraftDeleted(draftId));
    } catch (e) {
      emit(DraftError("Failed to delete draft: $e"));
    }
  }

  Future<void> clearStreams() async {
    _generation++;
    final subscription = _draftStreamSubscription;
    _draftStreamSubscription = null;
    if (subscription != null) await subscription.cancel();
    emit(DraftInitial());
  }

  @override
  Future<void> close() async {
    _generation++;
    final subscription = _draftStreamSubscription;
    _draftStreamSubscription = null;
    if (subscription != null) await subscription.cancel();
    return super.close();
  }
}
