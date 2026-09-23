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

  DraftSaved(this.draft);
}

class DraftDeleted extends DraftState {
  final String draftId;
  DraftDeleted(this.draftId);
}

class DraftError extends DraftState {
  final String message;
  DraftError(this.message);
}
