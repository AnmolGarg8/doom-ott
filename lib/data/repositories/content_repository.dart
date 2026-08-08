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

  @override
  Future<List<ContentModel>> getFeaturedContent() async {
    try {
      final response = await dioClient.get('/content', queryParameters: {'page': 1, 'page_size': 10});
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data['items'] as List;
        return items.map((e) => ContentModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ContentModel>> getTrendingContent() async {
    try {
      final response = await dioClient.get('/content', queryParameters: {'page': 1, 'page_size': 10});
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data['items'] as List;
        return items.map((e) => ContentModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ContentModel>> getContinueWatchingContent() async {
    try {
      final box = await Hive.openBox<ContentModel>('continue_watching');
      return box.values.toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<ContentModel>> getMovies() async {
    try {
      final response = await dioClient.get('/content', queryParameters: {'type': 'movie', 'page': 1, 'page_size': 20});
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data['items'] as List;
        return items.map((e) => ContentModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ContentModel>> getTVShows() async {
    try {
      final response = await dioClient.get('/content', queryParameters: {'type': 'series', 'page': 1, 'page_size': 20});
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data['items'] as List;
        return items.map((e) => ContentModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ContentModel>> getShorts() async {
    try {
      final response = await dioClient.get('/content', queryParameters: {'type': 'short', 'page': 1, 'page_size': 20});
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data['items'] as List;
        return items.map((e) => ContentModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ContentModel?> getContentById(String id) async {
    try {
      final response = await dioClient.get('/content/$id');
      if (response.statusCode == 200 && response.data != null) {
        return ContentModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ContentModel>> getSimilarContent(String id) async {
    try {
      final response = await dioClient.get('/content/$id/similar');
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data as List;
        return items.map((e) => ContentModel.fromJson(e as Map<String, dynamic>)).toList();
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
      final response = await dioClient.get('/content', queryParameters: {'search': query, 'page': 1, 'page_size': 20});
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data['items'] as List;
        return items.map((e) => ContentModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ContentModel>> getContentByGenre(String genre) async {
    try {
      final response = await dioClient.get('/content', queryParameters: {'genre': genre, 'page': 1, 'page_size': 20});
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data['items'] as List;
        return items.map((e) => ContentModel.fromJson(e as Map<String, dynamic>)).toList();
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
      final detail = e.response?.data is Map ? e.response?.data['detail'] : e.message;
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
