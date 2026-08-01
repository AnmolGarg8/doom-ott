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
    return MockData.allContent
        .where((element) => element.category == 'Featured')
        .toList();
  }

  @override
  Future<List<ContentModel>> getTrendingContent() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return MockData.allContent
        .where((element) => element.category == 'Trending Now')
        .toList();
  }

  @override
  Future<List<ContentModel>> getContinueWatchingContent() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.allContent
        .where((element) => element.category == 'Continue Watching')
        .toList();
  }

  @override
  Future<List<ContentModel>> getMovies() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return MockData.allContent.where((element) => element.isMovie).toList();
  }

  @override
  Future<List<ContentModel>> getTVShows() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return MockData.allContent.where((element) => !element.isMovie).toList();
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
    return MockData.allContent
        .where(
          (element) =>
              element.title.toLowerCase().contains(query.toLowerCase()) ||
              element.genres.any(
                (g) => g.toLowerCase().contains(query.toLowerCase()),
              ) ||
              element.cast.any(
                (c) => c.toLowerCase().contains(query.toLowerCase()),
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
              element.genres.any((g) => g.toLowerCase() == genre.toLowerCase()),
        )
        .toList();
  }
}
