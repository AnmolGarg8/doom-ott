import '../../../data/models/content_model.dart';

abstract class WatchlistState {}

class WatchlistInitial extends WatchlistState {}

class WatchlistLoading extends WatchlistState {}

class WatchlistLoaded extends WatchlistState {
  final List<ContentModel> watchlist;
  WatchlistLoaded(this.watchlist);
}

class WatchlistError extends WatchlistState {
  final String message;
  WatchlistError(this.message);
}
