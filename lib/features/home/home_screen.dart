import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'bloc/content_bloc.dart';
import 'bloc/content_event.dart';
import 'bloc/content_state.dart';
import '../../data/models/content_model.dart';
import '../../data/mock/mock_data.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/content_card.dart';
import '../../core/widgets/content_carousel.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  late PageController _heroPageController;
  Timer? _heroTimer;
  int _currentHeroPage = 0;

  @override
  void initState() {
    super.initState();
    _heroPageController = PageController(initialPage: 0);
    context.read<ContentBloc>().add(LoadHomeContent());
    _startHeroAutoScroll();
  }

  void _startHeroAutoScroll() {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_heroPageController.hasClients) {
        final nextPage =
            (_currentHeroPage + 1) % 5; // Assuming 5 featured items
        _heroPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroPageController.dispose();
    _heroTimer?.cancel();
    super.dispose();
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
          } else if (state is HomeContentLoaded) {
            final featuredList = state.featured.take(5).toList();

            return Stack(
              children: [
                // Scrollable Body
                RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context.read<ContentBloc>().add(LoadHomeContent());
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Hero Auto-Scrolling Banner Carousel
                        if (featuredList.isNotEmpty)
                          _buildHeroCarousel(featuredList),

                        const SizedBox(height: AppThemeConstants.space16),

                        // 2. Continue Watching Carousel (only if continueWatching is not empty)
                        if (state.continueWatching.isNotEmpty)
                          _buildContinueWatchingList(state.continueWatching),

                        // 3. Trending Now Carousel
                        if (state.trending.isNotEmpty)
                          ContentCarousel(
                            title: 'Trending Now',
                            items: state.trending,
                            onItemTap: (content) {
                              context.push('/content-detail/${content.id}');
                            },
                          ),

                        // 4. New Releases Carousel
                        if (state.movies.isNotEmpty)
                          ContentCarousel(
                            title: 'New Releases',
                            items: state.movies.take(8).toList(),
                            onItemTap: (content) {
                              context.push('/content-detail/${content.id}');
                            },
                          ),

                        // 5. Dynamic Genre-based Carousels (Action, Drama, Comedy, Originals)
                        ...['Action', 'Drama', 'Comedy', 'Originals'].map((
                          genre,
                        ) {
                          // Filter locally from all mock content
                          final genreItems = MockData.allContent
                              .where((item) => item.genre.contains(genre))
                              .toList();

                          if (genreItems.isEmpty) return const SizedBox();

                          return ContentCarousel(
                            title: '$genre Hits',
                            items: genreItems,
                            onItemTap: (content) {
                              context.push('/content-detail/${content.id}');
                            },
                          );
                        }),

                        const SizedBox(
                          height: 100,
                        ), // Spacing for bottom navbar
                      ],
                    ),
                  ),
                ),

                // Transparent-to-Solid CustomAppBar at the top of the stack
                CustomAppBar(
                  scrollController: _scrollController,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'DOOM',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is ContentError) {
            return Center(
              child: Text(
                'Failed to load content: ${state.message}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeroCarousel(List<ContentModel> featured) {
    return SizedBox(
      height: 480,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _heroPageController,
            onPageChanged: (index) {
              setState(() {
                _currentHeroPage = index;
              });
            },
            itemCount: featured.length,
            itemBuilder: (context, index) {
              final item = featured[index];
              return GestureDetector(
                onTap: () => context.push('/content-detail/${item.id}'),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Backdrop Image
                    CachedNetworkImage(
                      imageUrl: item.backdropUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: AppColors.surface),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.black),
                    ),
                    // Dark Gradient Overlays
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                            Colors.black87,
                            Colors.black,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.3, 0.75, 1.0],
                        ),
                      ),
                    ),
                    // Text and Action Buttons Overlay
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 32.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Genre Tags
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: item.genre.take(2).map((g) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
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
                          const SizedBox(height: 12),
                          // Title
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Tagline / Synopsis short
                          Text(
                            item.synopsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 20),
                          // Buttons Row
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  label: 'Watch Now',
                                  icon: LucideIcons.play,
                                  onPressed: () {
                                    context.push('/player/${item.id}');
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SecondaryButton(
                                  label: 'My List',
                                  icon: LucideIcons.plus,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Added ${item.title} to My List',
                                        ),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Page Indicator Dots
          Positioned(
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                featured.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentHeroPage == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentHeroPage == index
                        ? AppColors.primary
                        : AppColors.secondary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingList(List<ContentModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppThemeConstants.space16,
            vertical: AppThemeConstants.space8,
          ),
          child: Text(
            'Continue Watching',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppThemeConstants.space12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemeConstants.space4,
                ),
                child: SizedBox(
                  width: 180, // wider layout for continue watching
                  child: ContentCard(
                    content: item,
                    onTap: () => context.push('/content-detail/${item.id}'),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
