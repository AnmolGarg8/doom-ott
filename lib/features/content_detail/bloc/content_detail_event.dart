abstract class ContentDetailEvent {}

class LoadContentDetail extends ContentDetailEvent {
  final String id;
  LoadContentDetail(this.id);
}
