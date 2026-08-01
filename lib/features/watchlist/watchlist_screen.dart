import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'bloc/watchlist_bloc.dart';
import 'bloc/watchlist_event.dart';
import 'bloc/watchlist_state.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/widgets/content_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/content_model.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    _refreshLists();
  }

  Future<void> _refreshLists() async {
    // Read from Hive local storage database
    context.read<WatchlistBloc>().add(LoadWatchlist());
  }

  void _showRemoveBottomSheet(BuildContext context, ContentModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Remove from My List?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to remove "${item.title}" from your watchlist?',
                style: const TextStyle(color: AppColors.muted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeConstants.radiusButton,
                    ),
                  ),
                ),
                onPressed: () {
                  context.read<WatchlistBloc>().add(
                    RemoveFromWatchlistRequested(item.id),
                  );
                  Navigator.pop(modalContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed ${item.title} from My List.'),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeConstants.radiusButton,
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(modalContext),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'My Library',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.muted,
            tabs: [
              Tab(text: 'My List'),
              Tab(text: 'Continue Watching'),
            ],
          ),
        ),
        body: BlocBuilder<WatchlistBloc, WatchlistState>(
          builder: (context, state) {
            if (state is WatchlistLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (state is WatchlistLoaded) {
              final watchlist = state.watchlist;
              final continueWatching = state.continueWatching;

              return TabBarView(
                children: [
                  // Tab 1: My List
                  RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _refreshLists,
                    child: watchlist.isEmpty
                        ? EmptyState(
                            icon: LucideIcons.bookmark,
                            title: 'Your Watchlist is Empty',
                            description:
                                'Explore our catalog to add blockbusters, series, and shorts to My List.',
                            actionLabel: 'Browse Content',
                            onActionPressed: () => context.push('/browse'),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 2 / 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: watchlist.length,
                            itemBuilder: (context, index) {
                              final item = watchlist[index];
                              return GestureDetector(
                                onLongPress: () =>
                                    _showRemoveBottomSheet(context, item),
                                child: ContentCard(
                                  content: item,
                                  onTap: () => context.push(
                                    '/content-detail/${item.id}',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Tab 2: Continue Watching
                  RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _refreshLists,
                    child: continueWatching.isEmpty
                        ? EmptyState(
                            icon: LucideIcons.history,
                            title: 'No Watching History',
                            description:
                                'Start streaming your favorite series or movies to track progress here.',
                            actionLabel: 'Browse Content',
                            onActionPressed: () => context.push('/browse'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: continueWatching.length,
                            itemBuilder: (context, index) {
                              // Sorted by most recently watched (latest appended entries at the bottom or top?
                              // We reverse the list to show the most recently updated item at the top!)
                              final item = continueWatching.reversed
                                  .toList()[index];
                              return _buildContinueWatchingRow(item);
                            },
                          ),
                  ),
                ],
              );
            } else if (state is WatchlistError) {
              return Center(
                child: Text(
                  'Error loading library: ${state.message}',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContinueWatchingRow(ContentModel item) {
    final double progress = item.progress ?? 0.0;

    return GestureDetector(
      onTap: () => context.push('/player/${item.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppThemeConstants.radiusCard),
          border: Border.all(color: const Color(0xFF1F1F1F)),
        ),
        child: Row(
          children: [
            // Poster card with overlay progress lines
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppThemeConstants.radiusButton,
                  ),
                  child: Image.network(
                    item.posterUrl,
                    width: 70,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 4,
                  width: 70,
                  color: Colors.white24,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Metadata info details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(progress * 100).round()}% Completed',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.genre.join(', '),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              LucideIcons.playCircle,
              color: AppColors.primary,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
