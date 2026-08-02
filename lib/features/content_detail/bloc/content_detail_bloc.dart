import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/content_repository.dart';
import 'content_detail_event.dart';
import 'content_detail_state.dart';

class ContentDetailBloc extends Bloc<ContentDetailEvent, ContentDetailState> {
  final ContentRepository contentRepository;

  ContentDetailBloc({required this.contentRepository})
    : super(ContentDetailInitial()) {
    on<LoadContentDetail>(_onLoadContentDetail);
  }

  Future<void> _onLoadContentDetail(
    LoadContentDetail event,
    Emitter<ContentDetailState> emit,
  ) async {
    emit(ContentDetailLoading());
    try {
      final content = await contentRepository.getContentById(event.id);
      if (content != null) {
        emit(ContentDetailLoaded(content));
      } else {
        emit(ContentDetailError('Content not found'));
      }
    } catch (e) {
      emit(ContentDetailError(e.toString()));
    }
  }
}
