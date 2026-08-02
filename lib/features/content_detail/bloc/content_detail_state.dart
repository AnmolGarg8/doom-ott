import '../../../data/models/content_model.dart';

abstract class ContentDetailState {}

class ContentDetailInitial extends ContentDetailState {}

class ContentDetailLoading extends ContentDetailState {}

class ContentDetailLoaded extends ContentDetailState {
  final ContentModel content;
  ContentDetailLoaded(this.content);
}

class ContentDetailError extends ContentDetailState {
  final String message;
  ContentDetailError(this.message);
}
