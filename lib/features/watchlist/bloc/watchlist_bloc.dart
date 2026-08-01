import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/watchlist_repository.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistRepository watchlistRepository;

  WatchlistBloc({required this.watchlistRepository})
    : super(WatchlistInitial()) {
    on<LoadWatchlist>(_onLoadWatchlist);
    on<AddToWatchlistRequested>(_onAddToWatchlist);
    on<RemoveFromWatchlistRequested>(_onRemoveFromWatchlist);
    on<ToggleWatchlistRequested>(_onToggleWatchlist);
  }

  Future<void> _onLoadWatchlist(
    LoadWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(WatchlistLoading());
    try {
      final list = await watchlistRepository.getWatchlist();
      emit(WatchlistLoaded(list));
    } catch (e) {
      emit(WatchlistError(e.toString()));
    }
  }

  Future<void> _onAddToWatchlist(
    AddToWatchlistRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      await watchlistRepository.addToWatchlist(event.content);
      final list = await watchlistRepository.getWatchlist();
      emit(WatchlistLoaded(list));
    } catch (e) {
      emit(WatchlistError(e.toString()));
    }
  }

  Future<void> _onRemoveFromWatchlist(
    RemoveFromWatchlistRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      await watchlistRepository.removeFromWatchlist(event.id);
      final list = await watchlistRepository.getWatchlist();
      emit(WatchlistLoaded(list));
    } catch (e) {
      emit(WatchlistError(e.toString()));
    }
  }

  Future<void> _onToggleWatchlist(
    ToggleWatchlistRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      final isCurrentlyIn = await watchlistRepository.isInWatchlist(
        event.content.id,
      );
      if (isCurrentlyIn) {
        await watchlistRepository.removeFromWatchlist(event.content.id);
      } else {
        await watchlistRepository.addToWatchlist(event.content);
      }
      final list = await watchlistRepository.getWatchlist();
      emit(WatchlistLoaded(list));
    } catch (e) {
      emit(WatchlistError(e.toString()));
    }
  }
}
