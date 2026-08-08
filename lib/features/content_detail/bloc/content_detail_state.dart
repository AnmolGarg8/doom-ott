import '../../../data/models/content_model.dart';

abstract class ContentDetailState {}

class ContentDetailInitial extends ContentDetailState {}

class ContentDetailLoading extends ContentDetailState {}

class ContentDetailLoaded extends ContentDetailState {
  final ContentModel content;
  final List<ContentModel> similar;
  ContentDetailLoaded(this.content, {this.similar = const []});
}

class ContentDetailError extends ContentDetailState {
  final String message;
  ContentDetailError(this.message);
}
