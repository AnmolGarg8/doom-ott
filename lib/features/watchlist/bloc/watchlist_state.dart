import '../../../data/models/content_model.dart';

abstract class WatchlistState {}

class WatchlistInitial extends WatchlistState {}

class WatchlistLoading extends WatchlistState {}

class WatchlistLoaded extends WatchlistState {
  final List<ContentModel> watchlist;
  final List<ContentModel> continueWatching;
  WatchlistLoaded({required this.watchlist, required this.continueWatching});
}

class WatchlistError extends WatchlistState {
  final String message;
  WatchlistError(this.message);
}
