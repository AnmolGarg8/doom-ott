abstract class ContentEvent {}

class LoadHomeContent extends ContentEvent {}

class LoadContentDetail extends ContentEvent {
  final String id;
  LoadContentDetail(this.id);
}

class SearchContentRequested extends ContentEvent {
  final String query;
  SearchContentRequested(this.query);
}

class LoadGenreContent extends ContentEvent {
  final String genre;
  LoadGenreContent(this.genre);
}
