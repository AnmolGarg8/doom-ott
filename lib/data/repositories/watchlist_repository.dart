import 'package:hive_flutter/hive_flutter.dart';
import '../models/content_model.dart';

abstract class WatchlistRepository {
  Future<List<ContentModel>> getWatchlist();
  Future<void> addToWatchlist(ContentModel content);
  Future<void> removeFromWatchlist(String contentId);
  Future<bool> isInWatchlist(String contentId);

  Future<List<ContentModel>> getContinueWatching();
  Future<void> addToContinueWatching(ContentModel content);
}

class HiveWatchlistRepository implements WatchlistRepository {
  static const String _watchlistBoxName = 'watchlist';
  static const String _continueWatchingBoxName = 'continue_watching';

  Future<Box<ContentModel>> get _watchbox =>
      Hive.openBox<ContentModel>(_watchlistBoxName);
  Future<Box<ContentModel>> get _continueBox =>
      Hive.openBox<ContentModel>(_continueWatchingBoxName);

  @override
  Future<List<ContentModel>> getWatchlist() async {
    try {
      final box = await _watchbox;
      return box.values.toList();
    } catch (e) {
      // Malformed legacy data, clear the box to prevent screen crash
      try {
        final box = await _watchbox;
        await box.clear();
      } catch (_) {}
      return [];
    }
  }

  @override
  Future<void> addToWatchlist(ContentModel content) async {
    final box = await _watchbox;
    await box.put(content.id, content);
  }

  @override
  Future<void> removeFromWatchlist(String contentId) async {
    final box = await _watchbox;
    await box.delete(contentId);
  }

  @override
  Future<bool> isInWatchlist(String contentId) async {
    final box = await _watchbox;
    return box.containsKey(contentId);
  }

  @override
  Future<List<ContentModel>> getContinueWatching() async {
    try {
      final box = await _continueBox;
      return box.values.toList();
    } catch (e) {
      // Malformed legacy data, clear the box to prevent screen crash
      try {
        final box = await _continueBox;
        await box.clear();
      } catch (_) {}
      return [];
    }
  }

  @override
  Future<void> addToContinueWatching(ContentModel content) async {
    final box = await _continueBox;
    // We add or update the watch history for this content
    await box.put(content.id, content);
  }
}
