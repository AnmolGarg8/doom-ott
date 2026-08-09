import 'package:hive_flutter/hive_flutter.dart';
import '../../core/network/dio_client.dart';
import '../models/content_model.dart';
import '../mock/mock_data.dart';

abstract class WatchlistRepository {
  Future<List<ContentModel>> getWatchlist();
  Future<void> addToWatchlist(ContentModel content);
  Future<void> removeFromWatchlist(String contentId);
  Future<bool> isInWatchlist(String contentId);

  Future<List<ContentModel>> getContinueWatching();
  Future<void> addToContinueWatching(ContentModel content);
}

class RealWatchlistRepository implements WatchlistRepository {
  final DioClient dioClient;
  static const String _watchlistBoxName = 'watchlist';
  static const String _continueWatchingBoxName = 'continue_watching';

  RealWatchlistRepository({required this.dioClient});

  Future<Box<ContentModel>> get _watchbox =>
      Hive.openBox<ContentModel>(_watchlistBoxName);
  Future<Box<ContentModel>> get _continueBox =>
      Hive.openBox<ContentModel>(_continueWatchingBoxName);

  @override
  Future<List<ContentModel>> getWatchlist() async {
    final box = await _watchbox;
    final cached = box.values.toList();

    // Background sync with API
    _syncWatchlistFromBackend();

    return cached;
  }

  Future<bool> _isKidsMode() async {
    try {
      final profileBox = await Hive.openBox<dynamic>('user_profiles');
      final activeProfileId = profileBox.get('active_id') as String?;
      if (activeProfileId != null) {
        final profile = profileBox.get(activeProfileId) as Map?;
        if (profile != null) {
          return profile['isKids'] as bool? ?? false;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<void> _syncWatchlistFromBackend() async {
    try {
      final kidsMode = await _isKidsMode();
      final response = await dioClient.get(
        '/watchlist',
        queryParameters: kidsMode ? {'kids_mode': true} : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List;
        final box = await _watchbox;
        await box.clear();
        for (final item in list) {
          if (item['content'] != null) {
            final content = ContentModel.fromJson(
              item['content'] as Map<String, dynamic>,
            );
            await box.put(content.id, content);
          }
        }
      }
    } catch (_) {}
  }

  @override
  Future<void> addToWatchlist(ContentModel content) async {
    final box = await _watchbox;
    await box.put(content.id, content);

    try {
      await dioClient.post('/watchlist/${content.id}');
    } catch (_) {}
  }

  @override
  Future<void> removeFromWatchlist(String contentId) async {
    final box = await _watchbox;
    await box.delete(contentId);

    try {
      await dioClient.dio.delete('/watchlist/$contentId');
    } catch (_) {}
  }

  @override
  Future<bool> isInWatchlist(String contentId) async {
    final box = await _watchbox;
    return box.containsKey(contentId);
  }

  @override
  Future<List<ContentModel>> getContinueWatching() async {
    final box = await _continueBox;
    return box.values.toList();
  }

  @override
  Future<void> addToContinueWatching(ContentModel content) async {
    final box = await _continueBox;
    await box.put(content.id, content);

    try {
      final duration =
          content.durationSeconds ?? ((content.durationMinutes ?? 0) * 60);
      final posSeconds = ((content.progress ?? 0.0) * duration).toInt();
      await dioClient.dio.put(
        '/watch-progress/${content.id}',
        data: {'position_seconds': posSeconds},
      );
    } catch (_) {}
  }
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
      if (box.isEmpty) {
        final mockItems = MockData.allContent
            .where((element) => element.progress != null)
            .toList();
        for (final item in mockItems) {
          await box.put(item.id, item);
        }
      }
      return box.values.toList();
    } catch (e) {
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
    await box.put(content.id, content);
  }
}
