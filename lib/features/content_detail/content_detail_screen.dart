import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../home/bloc/content_bloc.dart';
import '../home/bloc/content_event.dart';
import '../home/bloc/content_state.dart';
import '../watchlist/bloc/watchlist_bloc.dart';
import '../watchlist/bloc/watchlist_event.dart';
import '../watchlist/bloc/watchlist_state.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/rating_badge.dart';
import '../../core/widgets/content_card.dart';
import '../../data/models/content_model.dart';
import '../../data/mock/mock_data.dart';

class ContentDetailScreen extends StatefulWidget {
  final String contentId;
  const ContentDetailScreen({super.key, required this.contentId});

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  bool _isSynopsisExpanded = false;
  String _selectedSeason = 'Season 1';

  final List<Map<String, String>> _cast = [
    {
      'name': 'Sarah Jenkins',
      'avatar': 'https://picsum.photos/seed/sarah/100/100',
    },
    {
      'name': 'Marcus Vance',
      'avatar': 'https://picsum.photos/seed/marcus/100/100',
    },
    {
      'name': 'Elena Rostova',
      'avatar': 'https://picsum.photos/seed/elena/100/100',
    },
    {
      'name': 'Tyler Durden',
      'avatar': 'https://picsum.photos/seed/tyler/100/100',
    },
    {
      'name': 'Aria Sterling',
      'avatar': 'https://picsum.photos/seed/aria/100/100',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void didUpdateWidget(covariant ContentDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contentId != widget.contentId) {
      _loadContent();
    }
  }

  void _loadContent() {
    context.read<ContentBloc>().add(LoadContentDetail(widget.contentId));
    context.read<WatchlistBloc>().add(LoadWatchlist());
  }

  List<Map<String, dynamic>> _getMockEpisodes(String contentId) {
    return List.generate(5, (index) {
      final epNum = index + 1;
      return {
        'title': 'Episode $epNum: Breach Frontiers',
        'duration': '45m',
        'thumbnail': 'https://picsum.photos/seed/${contentId}_ep$epNum/120/70',
        'description':
            'The battle reaches new heights as forces deploy along the borders. Old secrets are brought to light.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ContentBloc, ContentState>(
        builder: (context, state) {
          if (state is ContentLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is ContentDetailLoaded) {
            final content = state.content;

            // Fetch similar content in the same genre
            final similarContent = MockData.allContent
                .where(
                  (item) =>
                      item.id != content.id &&
                      item.genre.any((g) => content.genre.contains(g)),
                )
                .take(6)
                .toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Backdrop image with gradients and text overlays
                  _buildBackdropHeader(content),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 2. Action row
                        _buildActionRow(content),
                        const SizedBox(height: 24),

                        // 3. Synopsis expandable text
                        _buildSynopsisSection(content),
                        const SizedBox(height: 24),

                        // 4. Cast Section
                        _buildCastSection(),
                        const SizedBox(height: 24),

                        // 5. Episode List (only if type == series)
                        if (content.type == 'series')
                          _buildEpisodesSection(content),

                        // 6. More Like This Section
                        if (similarContent.isNotEmpty)
                          _buildSimilarSection(similarContent),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ContentError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildBackdropHeader(ContentModel content) {
    final double backdropHeight = MediaQuery.of(context).size.height * 0.40;

    return Stack(
      children: [
        // Backdrop Image
        CachedNetworkImage(
          imageUrl: content.backdropUrl,
          width: double.infinity,
          height: backdropHeight,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: backdropHeight,
            color: AppColors.surface,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: backdropHeight,
            color: AppColors.surface,
            child: const Icon(
              LucideIcons.video,
              size: 48,
              color: AppColors.muted,
            ),
          ),
        ),

        // Gradient overlay fading to black at the bottom
        Container(
          height: backdropHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black45,
                Colors.transparent,
                Colors.black87,
                Colors.black,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 0.85, 1.0],
            ),
          ),
        ),

        // Float navigation back button
        Positioned(
          top: 40,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(
                LucideIcons.arrowLeft,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
          ),
        ),

        // Text details overlay
        Positioned(
          bottom: 12,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metadata Row (Release Year, Duration/Episodes)
              Row(
                children: [
                  RatingBadge(
                    rating: 7.0 + (int.tryParse(content.id) ?? 5) % 3 * 0.9,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      content.rating,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    content.releaseYear,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    content.type == 'series'
                        ? 'TV Series'
                        : '${content.durationMinutes} mins',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                content.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Genres Row
              Wrap(
                spacing: 6,
                children: content.genre.map((g) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      g,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(ContentModel content) {
    return Row(
      children: [
        // Play Button
        Expanded(
          child: PrimaryButton(
            label: 'Play',
            icon: LucideIcons.play,
            onPressed: () => context.push('/player/${content.id}'),
          ),
        ),
        const SizedBox(width: 16),

        // Watchlist add/remove toggle (Optimistic Update)
        BlocBuilder<WatchlistBloc, WatchlistState>(
          builder: (context, state) {
            final isAdded =
                state is WatchlistLoaded &&
                state.watchlist.any((item) => item.id == content.id);

            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white30),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isAdded ? LucideIcons.check : LucideIcons.plus,
                  color: isAdded ? AppColors.primary : Colors.white,
                ),
                onPressed: () {
                  context.read<WatchlistBloc>().add(
                    ToggleWatchlistRequested(content),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAdded
                            ? 'Removed ${content.title} from My List.'
                            : 'Added ${content.title} to My List.',
                      ),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(width: 12),

        // Share button
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white30),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(LucideIcons.share2, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link copied to clipboard!'),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSynopsisSection(ContentModel content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Synopsis',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content.synopsis,
          maxLines: _isSynopsisExpanded ? null : 3,
          overflow: _isSynopsisExpanded
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        if (content.synopsis.length > 120) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSynopsisExpanded = !_isSynopsisExpanded;
              });
            },
            child: Text(
              _isSynopsisExpanded ? 'Show Less' : 'Read More',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cast',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _cast.length,
            itemBuilder: (context, index) {
              final member = _cast[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: NetworkImage(member['avatar']!),
                      backgroundColor: AppColors.surface,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      member['name']!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodesSection(ContentModel content) {
    final episodes = _getMockEpisodes(content.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.white10, height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Episodes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            // Season Selector Dropdown
            DropdownButton<String>(
              value: _selectedSeason,
              dropdownColor: AppColors.surface,
              underline: const SizedBox(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              items: const [
                DropdownMenuItem(value: 'Season 1', child: Text('Season 1')),
                DropdownMenuItem(value: 'Season 2', child: Text('Season 2')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedSeason = val;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Episode List Items
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: episodes.length,
          itemBuilder: (context, index) {
            final ep = episodes[index];
            return GestureDetector(
              onTap: () => context.push('/player/${content.id}'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppThemeConstants.radiusCard,
                  ),
                  border: Border.all(color: const Color(0xFF1F1F1F)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Episode Image Preview with Play Overlay
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppThemeConstants.radiusButton,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: ep['thumbnail'] as String,
                            width: 110,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black45,
                          child: Icon(
                            LucideIcons.play,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Episode Title and Duration
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ep['title'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                ep['duration'] as String,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ep['description'] as String,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSimilarSection(List<ContentModel> similar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.white10, height: 32),
        const Text(
          'More Like This',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: similar.length,
            itemBuilder: (context, index) {
              final item = similar[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SizedBox(
                  width: 120,
                  child: ContentCard(
                    content: item,
                    onTap: () {
                      context.push('/content-detail/${item.id}');
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
