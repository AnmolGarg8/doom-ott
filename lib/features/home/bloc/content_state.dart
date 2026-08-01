import '../../../data/models/content_model.dart';

abstract class ContentState {}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {}

class HomeContentLoaded extends ContentState {
  final List<ContentModel> featured;
  final List<ContentModel> trending;
  final List<ContentModel> continueWatching;
  final List<ContentModel> movies;
  final List<ContentModel> tvShows;

  HomeContentLoaded({
    required this.featured,
    required this.trending,
    required this.continueWatching,
    required this.movies,
    required this.tvShows,
  });
}

class ContentDetailLoaded extends ContentState {
  final ContentModel content;
  ContentDetailLoaded(this.content);
}

class SearchResultsLoaded extends ContentState {
  final List<ContentModel> results;
  SearchResultsLoaded(this.results);
}

class GenreContentLoaded extends ContentState {
  final List<ContentModel> content;
  GenreContentLoaded(this.content);
}

class ContentError extends ContentState {
  final String message;
  ContentError(this.message);
}
