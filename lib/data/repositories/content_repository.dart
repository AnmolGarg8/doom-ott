import '../models/content_model.dart';
import '../mock/mock_data.dart';

abstract class ContentRepository {
  Future<List<ContentModel>> getFeaturedContent();
  Future<List<ContentModel>> getTrendingContent();
  Future<List<ContentModel>> getContinueWatchingContent();
  Future<List<ContentModel>> getMovies();
  Future<List<ContentModel>> getTVShows();
  Future<ContentModel?> getContentById(String id);
  Future<List<ContentModel>> searchContent(String query);
  Future<List<ContentModel>> getContentByGenre(String genre);
}

class MockContentRepository implements ContentRepository {
  @override
  Future<List<ContentModel>> getFeaturedContent() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Return items marked as Originals as featured
    return MockData.allContent
        .where((element) => element.genre.contains('Originals'))
        .take(5)
        .toList();
  }

  @override
  Future<List<ContentModel>> getTrendingContent() async {
    await Future.delayed(const Duration(milliseconds: 700));
    // Return a subset of trending items
    final trendingIds = ['1', '8', '9', '10', '13', '21', '24'];
    return MockData.allContent
        .where((element) => trendingIds.contains(element.id))
        .toList();
  }

  @override
  Future<List<ContentModel>> getContinueWatchingContent() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return items that have active progress
    return MockData.allContent
        .where((element) => element.progress != null)
        .toList();
  }

  @override
  Future<List<ContentModel>> getMovies() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return MockData.allContent
        .where((element) => element.type == 'movie' || element.type == 'short')
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
  Future<ContentModel?> getContentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return MockData.allContent.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
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
}
