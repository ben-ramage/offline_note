import 'package:offline_note/features/create/domain/entities/post.dart';

abstract class DraftState {}

class DraftInitial extends DraftState {}

class DraftLoading extends DraftState {}

class DraftSaving extends DraftState {}

class DraftsLoaded extends DraftState {
  final List<Post> drafts;

  DraftsLoaded(this.drafts);
}

class DraftSaved extends DraftState {
  final Post draft;
  final String requestId;

  DraftSaved({required this.draft, required this.requestId});
}

class DraftSaveFailed extends DraftState {
  final String draftId;
  final String requestId;
  final String message;

  DraftSaveFailed({
    required this.draftId,
    required this.requestId,
    required this.message,
  });
}

class DraftDeleted extends DraftState {
  final String draftId;
  DraftDeleted(this.draftId);
}

class DraftError extends DraftState {
  final String message;
  DraftError(this.message);
}
