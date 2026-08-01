import '../../../data/models/content_model.dart';

abstract class WatchlistEvent {}

class LoadWatchlist extends WatchlistEvent {}

class AddToWatchlistRequested extends WatchlistEvent {
  final ContentModel content;
  AddToWatchlistRequested(this.content);
}

class RemoveFromWatchlistRequested extends WatchlistEvent {
  final String id;
  RemoveFromWatchlistRequested(this.id);
}

class ToggleWatchlistRequested extends WatchlistEvent {
  final ContentModel content;
  ToggleWatchlistRequested(this.content);
}
