import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:hive/hive.dart';
import '../../core/network/dio_client.dart';
import '../models/content_model.dart';
import '../mock/mock_data.dart';

abstract class ContentRepository {
  Future<List<ContentModel>> getFeaturedContent();
  Future<List<ContentModel>> getTrendingContent();
  Future<List<ContentModel>> getContinueWatchingContent();
  Future<List<ContentModel>> getMovies();
  Future<List<ContentModel>> getTVShows();
  Future<List<ContentModel>> getShorts();
  Future<ContentModel?> getContentById(String id);
  Future<List<ContentModel>> getSimilarContent(String id);
  Future<List<ContentModel>> searchContent(String query);
  Future<List<ContentModel>> getContentByGenre(String genre);
  Future<List<String>> getCategories();
  Future<String> getPlaybackUrl(String id);

  // Cached methods for instant-first-paint
  Future<List<ContentModel>> getCachedFeaturedContent();
  Future<List<ContentModel>> getCachedTrendingContent();
  Future<List<ContentModel>> getCachedMovies();
  Future<List<ContentModel>> getCachedTVShows();
  Future<List<ContentModel>> getCachedShorts();
  Future<ContentModel?> getCachedContentById(String id);
  Future<List<ContentModel>> getCachedContentByGenre(String genre);
}

class RealContentRepository implements ContentRepository {
  final DioClient dioClient;

  final Logger logger = Logger();

  RealContentRepository({required this.dioClient});

  Future<Box<dynamic>> get _contentCacheBox =>
      Hive.openBox<dynamic>('content_cache');

  Future<void> _saveCache(String key, List<ContentModel> items) async {
    try {
      final box = await _contentCacheBox;
      await box.put(key, items.map((e) => e.toJson()).toList());
    } catch (e) {
      logger.e('Failed to save cache for $key: $e');
    }
  }

  Future<List<ContentModel>> _getCacheList(String key) async {
    try {
      final box = await _contentCacheBox;
      final raw = box.get(key) as List?;
      if (raw != null) {
        return raw
            .map((e) => ContentModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (e) {
      logger.e('Failed to read cache for $key: $e');
    }
    return [];
  }

  Future<void> _saveSingleCache(String key, ContentModel item) async {
    try {
      final box = await _contentCacheBox;
      await box.put(key, item.toJson());
    } catch (e) {
      logger.e('Failed to save single cache for $key: $e');
    }
  }

  Future<ContentModel?> _getSingleCache(String key) async {
    try {
      final box = await _contentCacheBox;
      final raw = box.get(key) as Map?;
      if (raw != null) {
        return ContentModel.fromJson(Map<String, dynamic>.from(raw));
      }
    } catch (e) {
      logger.e('Failed to read single cache for $key: $e');
    }
    return null;
  }

  @override
  Future<List<ContentModel>> getCachedFeaturedContent() => _getCacheList('featured');

  @override
  Future<List<ContentModel>> getCachedTrendingContent() => _getCacheList('trending');

  @override
  Future<List<ContentModel>> getCachedMovies() => _getCacheList('movies');

  @override
  Future<List<ContentModel>> getCachedTVShows() => _getCacheList('tv_shows');

  @override
  Future<List<ContentModel>> getCachedShorts() => _getCacheList('shorts');

  @override
  Future<ContentModel?> getCachedContentById(String id) => _getSingleCache('content_$id');

  @override
  Future<List<ContentModel>> getCachedContentByGenre(String genre) =>
      _getCacheList('genre_$genre');

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
    } catch (e) {
      logger.e('Failed to check kids mode: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>> _buildQueryParams(Map<String, dynamic> base) async {
    final Map<String, dynamic> params = Map<String, dynamic>.from(base);
    final kidsMode = await _isKidsMode();
    if (kidsMode) {
      params['kids_mode'] = true;
    }
    return params;
  }

  @override
  Future<List<ContentModel>> getFeaturedContent() async {
    try {
      final response = await dioClient.get(
        '/content',
        queryParameters: await _buildQueryParams({'page': 1, 'page_size': 10}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final items = (response.data['items'] as List)
            .map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await _saveCache('featured', items);
        return items;
      }
      return await getCachedFeaturedContent();
    } catch (e) {
      return await getCachedFeaturedContent();
    }
  }

  @override
  Future<List<ContentModel>> getTrendingContent() async {
    try {
      final response = await dioClient.get(
        '/content',
        queryParameters: await _buildQueryParams({'page': 1, 'page_size': 10}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final items = (response.data['items'] as List)
            .map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await _saveCache('trending', items);
        return items;
      }
      return await getCachedTrendingContent();
    } catch (e) {
      return await getCachedTrendingContent();
    }
  }

  @override
  Future<List<ContentModel>> getContinueWatchingContent() async {
    try {
      final profileBox = await Hive.openBox<dynamic>('user_profiles');
      final activeProfileId = profileBox.get('active_id') as String?;
      if (activeProfileId == null || activeProfileId.isEmpty) {
        throw Exception('No active profile found.');
      }

      final response = await dioClient.get(
        '/watch-progress',
        queryParameters: await _buildQueryParams({'profile_id': activeProfileId}),
      );

      final List<ContentModel> list = [];
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data as List;
        for (final item in items) {
          final map = Map<String, dynamic>.from(item as Map);
          if (map['content'] != null) {
            final contentJson = Map<String, dynamic>.from(
              map['content'] as Map,
            );
            final positionSeconds = map['position_seconds'] as int? ?? 0;

            final content = ContentModel.fromJson(contentJson);
            final duration =
                content.durationSeconds ??
                (content.durationMinutes != null
                    ? content.durationMinutes! * 60
                    : null);
            double? progress;
            if (duration != null && duration > 0) {
              progress = (positionSeconds / duration).clamp(0.0, 1.0);
            }

            list.add(content.copyWith(progress: progress));
          }
        }

        final box = await Hive.openBox<ContentModel>('continue_watching');
        await box.clear();
        for (final item in list) {
          await box.put(item.id, item);
        }
      }

      final box = await Hive.openBox<ContentModel>('continue_watching');
      return box.values.toList();
    } catch (e) {
      try {
        final box = await Hive.openBox<ContentModel>('continue_watching');
        return box.values.toList();
      } catch (_) {
        return [];
      }
    }
  }

  @override
  Future<List<ContentModel>> getMovies() async {
    try {
      final response = await dioClient.get(
        '/content',
        queryParameters: await _buildQueryParams({'type': 'movie', 'page': 1, 'page_size': 20}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final items = (response.data['items'] as List)
            .map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await _saveCache('movies', items);
        return items;
      }
      return await getCachedMovies();
    } catch (e) {
      return await getCachedMovies();
    }
  }

  @override
  Future<List<ContentModel>> getTVShows() async {
    try {
      final response = await dioClient.get(
        '/content',
        queryParameters: await _buildQueryParams({'type': 'series', 'page': 1, 'page_size': 20}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final items = (response.data['items'] as List)
            .map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await _saveCache('tv_shows', items);
        return items;
      }
      return await getCachedTVShows();
    } catch (e) {
      return await getCachedTVShows();
    }
  }

  @override
  Future<List<ContentModel>> getShorts() async {
    try {
      final response = await dioClient.get(
        '/content',
        queryParameters: await _buildQueryParams({'type': 'short', 'page': 1, 'page_size': 20}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final items = (response.data['items'] as List)
            .map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await _saveCache('shorts', items);
        return items;
      }
      return await getCachedShorts();
    } catch (e) {
      return await getCachedShorts();
    }
  }

  @override
  Future<ContentModel?> getContentById(String id) async {
    try {
      final response = await dioClient.get(
        '/content/$id',
        queryParameters: await _buildQueryParams({}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final content = ContentModel.fromJson(response.data as Map<String, dynamic>);
        await _saveSingleCache('content_$id', content);
        return content;
      }
      return await getCachedContentById(id);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("This title isn't available in Kids Mode");
      }
      final detail = e.response?.data is Map
          ? e.response?.data['detail']
          : e.message;
      throw Exception(detail ?? 'Failed to fetch content details');
    } catch (e) {
      final cached = await getCachedContentById(id);
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<List<ContentModel>> getSimilarContent(String id) async {
    try {
      final response = await dioClient.get(
        '/content/$id/similar',
        queryParameters: await _buildQueryParams({}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data as List;
        return items
            .map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ContentModel>> searchContent(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await dioClient.get(
        '/content',
        queryParameters: await _buildQueryParams({'search': query, 'page': 1, 'page_size': 20}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data['items'] as List;
        return items
            .map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ContentModel>> getContentByGenre(String genre) async {
    try {
      final response = await dioClient.get(
        '/content',
        queryParameters: await _buildQueryParams({'genre': genre, 'page': 1, 'page_size': 20}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final items = (response.data['items'] as List)
            .map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await _saveCache('genre_$genre', items);
        return items;
      }
      return await getCachedContentByGenre(genre);
    } catch (e) {
      return await getCachedContentByGenre(genre);
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await dioClient.get('/categories');
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data as List;
        return items.map((e) => (e['name'] as String)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String> getPlaybackUrl(String id) async {
    try {
      final response = await dioClient.get('/content/$id/playback-url');
      if (response.statusCode == 200 && response.data != null) {
        return response.data['playback_url'] as String;
      }
      throw Exception('Failed to fetch playback URL');
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? e.response?.data['detail']
          : e.message;
      throw Exception(detail ?? 'Failed to fetch playback URL');
    }
  }
}

class MockContentRepository implements ContentRepository {
  @override
  Future<List<ContentModel>> getCachedFeaturedContent() async => [];
  @override
  Future<List<ContentModel>> getCachedTrendingContent() async => [];
  @override
  Future<List<ContentModel>> getCachedMovies() async => [];
  @override
  Future<List<ContentModel>> getCachedTVShows() async => [];
  @override
  Future<List<ContentModel>> getCachedShorts() async => [];
  @override
  Future<ContentModel?> getCachedContentById(String id) async => null;
  @override
  Future<List<ContentModel>> getCachedContentByGenre(String genre) async => [];
  @override
  Future<List<ContentModel>> getFeaturedContent() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockData.allContent
        .where((element) => element.genre.contains('Originals'))
        .take(5)
        .toList();
  }

  @override
  Future<List<ContentModel>> getTrendingContent() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final trendingIds = ['1', '8', '9', '10', '13', '21', '24'];
    return MockData.allContent
        .where((element) => trendingIds.contains(element.id))
        .toList();
  }

  @override
  Future<List<ContentModel>> getContinueWatchingContent() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final box = await Hive.openBox<ContentModel>('continue_watching');
      if (box.isEmpty) {
        final mockItems = MockData.allContent
            .where((element) => element.progress != null)
            .toList();
        for (final item in mockItems) {
          await box.put(item.id, item);
        }
      }
      return box.values.toList();
    } catch (_) {
      return MockData.allContent
          .where((element) => element.progress != null)
          .toList();
    }
  }

  @override
  Future<List<ContentModel>> getMovies() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return MockData.allContent
        .where((element) => element.type == 'movie')
        .toList();
  }

  @override
  Future<List<ContentModel>> getTVShows() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return MockData.allContent
        .where((element) => element.type == 'series')
        .toList();
  }

  @override
  Future<List<ContentModel>> getShorts() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return MockData.allContent
        .where((element) => element.type == 'short')
        .toList();
  }

  @override
  Future<ContentModel?> getContentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return MockData.allContent.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ContentModel>> getSimilarContent(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final content = await getContentById(id);
    if (content == null) return [];
    return MockData.allContent
        .where(
          (element) =>
              element.id != id &&
              element.genre.any((g) => content.genre.contains(g)),
        )
        .take(6)
        .toList();
  }

  @override
  Future<List<ContentModel>> searchContent(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (query.isEmpty) return [];
    final lowercaseQuery = query.toLowerCase();
    return MockData.allContent
        .where(
          (element) =>
              element.title.toLowerCase().contains(lowercaseQuery) ||
              element.synopsis.toLowerCase().contains(lowercaseQuery) ||
              element.genre.any(
                (g) => g.toLowerCase().contains(lowercaseQuery),
              ),
        )
        .toList();
  }

  @override
  Future<List<ContentModel>> getContentByGenre(String genre) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.allContent
        .where(
          (element) =>
              element.genre.any((g) => g.toLowerCase() == genre.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ['Action', 'Sci-Fi', 'Animation', 'Drama', 'Comedy', 'Thriller'];
  }

  @override
  Future<String> getPlaybackUrl(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
  }
}
