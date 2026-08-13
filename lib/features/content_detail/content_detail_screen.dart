import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/widgets/empty_state.dart';
import 'bloc/content_detail_bloc.dart';
import 'bloc/content_detail_event.dart';
import 'bloc/content_detail_state.dart';
import '../watchlist/bloc/watchlist_bloc.dart';
import '../watchlist/bloc/watchlist_event.dart';
import '../watchlist/bloc/watchlist_state.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/rating_badge.dart';
import '../../core/widgets/content_card.dart';
import '../../data/models/content_model.dart';

class ContentDetailScreen extends StatefulWidget {
  final String contentId;
  const ContentDetailScreen({super.key, required this.contentId});

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  bool _isSynopsisExpanded = false;
  String _selectedSeason = 'Season 1';
  List<Map<String, dynamic>> _reviewsList = [];
  double _averageRating = 4.5;

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
    context.read<ContentDetailBloc>().add(LoadContentDetail(widget.contentId));
    context.read<WatchlistBloc>().add(LoadWatchlist());
    _reviewsList = _getInitialReviews(widget.contentId);
    _recalculateAverage();
  }

  List<Map<String, dynamic>> _getInitialReviews(String contentId) {
    return [
      {
        'userName': 'Aarav Mehta',
        'rating': 5,
        'text':
            'Absolutely stunning! The visual effects and sound design are top tier. A must watch on a large screen.',
        'date': 'Aug 01, 2026',
      },
      {
        'userName': 'Priya Sharma',
        'rating': 4,
        'text':
            'Great storyline and acting. The pacing is a bit slow in the middle, but the climax makes up for it completely.',
        'date': 'Jul 30, 2026',
      },
    ];
  }

  void _recalculateAverage() {
    if (_reviewsList.isEmpty) {
      setState(() {
        _averageRating = 4.5;
      });
      return;
    }
    final total = _reviewsList.fold<double>(
      0.0,
      (sum, item) => sum + (item['rating'] as num).toDouble(),
    );
    setState(() {
      _averageRating = total / _reviewsList.length;
    });
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
      body: BlocBuilder<ContentDetailBloc, ContentDetailState>(
        builder: (context, state) {
          if (state is ContentDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is ContentDetailLoaded) {
            final content = state.content;

            final similarContent = state.similar;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<ContentDetailBloc>().add(
                      LoadContentDetail(widget.contentId),
                    );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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

                          // Reviews section
                          _buildReviewsSection(content),
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
              ),
            );
          } else if (state is ContentDetailError) {
            final isKidsForbidden = state.message.contains("Kids Mode") ||
                state.message.contains("isn't available");
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
              body: EmptyState(
                icon: LucideIcons.shieldAlert,
                title: 'Restricted Content',
                description: isKidsForbidden
                    ? "This title isn't available in Kids Mode"
                    : 'Error: ${state.message}',
                actionLabel: 'Go Back',
                onActionPressed: () => context.pop(),
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
                  RatingBadge(rating: _averageRating),
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
                        : '${content.durationMinutes ?? 0} mins',
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
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // Rate Button
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white30),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(LucideIcons.star, color: Colors.white),
            onPressed: () => _showRatingBottomSheet(context, content),
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

  void _showRatingBottomSheet(BuildContext context, ContentModel content) {
    int selectedStars = 5;
    final TextEditingController textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Rate "${content.title}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNum = index + 1;
                      final isSelected = starNum <= selectedStars;
                      return IconButton(
                        icon: Icon(
                          LucideIcons.star,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white10,
                          size: 32,
                        ),
                        onPressed: () {
                          setModalState(() {
                            selectedStars = starNum;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Write an optional review...',
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Submit Rating',
                    onPressed: () {
                      final enteredText = textController.text.trim();
                      setState(() {
                        _reviewsList.insert(0, {
                          'userName': 'You',
                          'rating': selectedStars,
                          'text': enteredText.isEmpty
                              ? 'Outstanding streaming title!'
                              : enteredText,
                          'date': 'Just Now',
                        });
                        _recalculateAverage();
                      });
                      Navigator.pop(modalContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Thank you! Your rating has been submitted.',
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewsSection(ContentModel content) {
    final List<Color> avatarColors = const [
      Colors.amber,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.orange,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.white10, height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'User Reviews',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push(
                  '/reviews?id=${content.id}&title=${Uri.encodeComponent(content.title)}',
                );
              },
              child: const Text(
                'See All Reviews',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_reviewsList.isEmpty)
          const Text(
            'No reviews yet. Be the first to review!',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          )
        else
          ..._reviewsList.take(2).map((rev) {
            final idx = _reviewsList.indexOf(rev);
            final avatarColor = avatarColors[idx % avatarColors.length];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: avatarColor,
                            child: Text(
                              rev['userName']
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            rev['userName'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        rev['date'] as String,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        LucideIcons.star,
                        color: index < (rev['rating'] as int)
                            ? AppColors.primary
                            : Colors.white10,
                        size: 10,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rev['text'] as String,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
