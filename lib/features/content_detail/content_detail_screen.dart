import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../home/bloc/content_bloc.dart';
import '../home/bloc/content_event.dart';
import '../home/bloc/content_state.dart';
import '../watchlist/bloc/watchlist_bloc.dart';
import '../watchlist/bloc/watchlist_event.dart';
import '../watchlist/bloc/watchlist_state.dart';
import '../../core/theme/colors.dart';

class ContentDetailScreen extends StatefulWidget {
  final String contentId;

  const ContentDetailScreen({super.key, required this.contentId});

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ContentBloc>().add(LoadContentDetail(widget.contentId));
    context.read<WatchlistBloc>().add(LoadWatchlist());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ContentBloc, ContentState>(
        builder: (context, state) {
          if (state is ContentLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is ContentDetailLoaded) {
            final content = state.content;

            return CustomScrollView(
              slivers: [
                // Header Image Banner
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: AppColors.background,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: content.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Container(color: AppColors.surface),
                        ),
                        // Dark Overlay Gradient
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black54,
                                Colors.transparent,
                                Colors.black,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),

                // Details Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          content.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Meta details
                        Row(
                          children: [
                            Text(
                              content.releaseYear,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.muted),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                content.rating,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              content.duration,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.background,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () =>
                                    context.push('/player/${content.id}'),
                                icon: const Icon(
                                  LucideIcons.play,
                                  color: Colors.black,
                                ),
                                label: const Text(
                                  'Play Now',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Watchlist toggle button
                            BlocBuilder<WatchlistBloc, WatchlistState>(
                              builder: (context, watchlistState) {
                                bool isInWatchlist = false;
                                if (watchlistState is WatchlistLoaded) {
                                  isInWatchlist = watchlistState.watchlist.any(
                                    (item) => item.id == content.id,
                                  );
                                }

                                return Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.onBackground,
                                      side: BorderSide(
                                        color: isInWatchlist
                                            ? AppColors.primary
                                            : Colors.white30,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      context.read<WatchlistBloc>().add(
                                        ToggleWatchlistRequested(content),
                                      );
                                    },
                                    icon: Icon(
                                      isInWatchlist
                                          ? LucideIcons.check
                                          : LucideIcons.plus,
                                      color: isInWatchlist
                                          ? AppColors.primary
                                          : Colors.white,
                                    ),
                                    label: Text(
                                      isInWatchlist
                                          ? 'Watchlisted'
                                          : 'Add to List',
                                      style: TextStyle(
                                        color: isInWatchlist
                                            ? AppColors.primary
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Synopsis
                        const Text(
                          'Synopsis',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          content.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.muted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Genres
                        const Text(
                          'Genres',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: content.genres
                              .map(
                                (genre) => Chip(
                                  label: Text(genre),
                                  backgroundColor: AppColors.surface,
                                  side: const BorderSide(
                                    color: Color(0xFF1F1F1F),
                                  ),
                                  labelStyle: const TextStyle(
                                    color: AppColors.onBackground,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),

                        // Cast
                        const Text(
                          'Starring',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          content.cast.join(', '),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is ContentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load details: ${state.message}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ContentBloc>().add(
                        LoadContentDetail(widget.contentId),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
