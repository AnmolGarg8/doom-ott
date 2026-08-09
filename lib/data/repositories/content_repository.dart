import 'package:dio/dio.dart';
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
}

class RealContentRepository implements ContentRepository {
  final DioClient dioClient;

  RealContentRepository({required this.dioClient});

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
  Future<List<ContentModel>> getTrendingContent() async {
    try {
      final response = await dioClient.get(
        '/content',
        queryParameters: await _buildQueryParams({'page': 1, 'page_size': 10}),
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
  Future<List<ContentModel>> getTVShows() async {
    try {
      final response = await dioClient.get(
        '/content',
        queryParameters: await _buildQueryParams({'type': 'series', 'page': 1, 'page_size': 20}),
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
  Future<List<ContentModel>> getShorts() async {
    try {
      final response = await dioClient.get(
        '/content',
        queryParameters: await _buildQueryParams({'type': 'short', 'page': 1, 'page_size': 20}),
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
  Future<ContentModel?> getContentById(String id) async {
    try {
      final response = await dioClient.get(
        '/content/$id',
        queryParameters: await _buildQueryParams({}),
      );
      if (response.statusCode == 200 && response.data != null) {
        return ContentModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("This title isn't available in Kids Mode");
      }
      final detail = e.response?.data is Map
          ? e.response?.data['detail']
          : e.message;
      throw Exception(detail ?? 'Failed to fetch content details');
    } catch (e) {
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
