import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'bloc/content_bloc.dart';
import 'bloc/content_event.dart';
import 'bloc/content_state.dart';
import '../../data/models/content_model.dart';
import '../../core/theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ContentBloc>().add(LoadHomeContent());
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
          } else if (state is HomeContentLoaded) {
            final featured = state.featured.isNotEmpty
                ? state.featured.first
                : null;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<ContentBloc>().add(LoadHomeContent());
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Image
                    if (featured != null) _buildFeaturedBanner(featured),

                    // Continue Watching
                    if (state.continueWatching.isNotEmpty) ...[
                      _buildSectionHeader('Continue Watching'),
                      _buildHorizontalList(
                        state.continueWatching,
                        isWide: true,
                      ),
                    ],

                    // Trending
                    if (state.trending.isNotEmpty) ...[
                      _buildSectionHeader('Trending Now'),
                      _buildHorizontalList(state.trending),
                    ],

                    // Movies
                    if (state.movies.isNotEmpty) ...[
                      _buildSectionHeader('Blockbuster Movies'),
                      _buildHorizontalList(state.movies),
                    ],

                    // TV Shows
                    if (state.tvShows.isNotEmpty) ...[
                      _buildSectionHeader('Must-Watch TV Shows'),
                      _buildHorizontalList(state.tvShows),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
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

  Widget _buildFeaturedBanner(ContentModel content) {
    return Stack(
      children: [
        // Image
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: content.thumbnailUrl,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) =>
                Container(color: AppColors.surface),
          ),
        ),
        // Dark Overlay Gradient
        Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black45, Colors.transparent, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 1.0],
            ),
          ),
        ),
        // Content details
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                content.title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Meta Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 12),
              // Genres
              Wrap(
                spacing: 8,
                children: content.genres
                    .map(
                      (g) => Chip(
                        label: Text(
                          g,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.onBackground,
                          ),
                        ),
                        backgroundColor: Colors.white10,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => context.push('/player/${content.id}'),
                      icon: const Icon(
                        LucideIcons.play,
                        color: Colors.black,
                        size: 16,
                      ),
                      label: const Text(
                        'Play',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onBackground,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () =>
                          context.push('/content-detail/${content.id}'),
                      icon: const Icon(LucideIcons.info, size: 16),
                      label: const Text('Details'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.onBackground,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<ContentModel> list, {bool isWide = false}) {
    return SizedBox(
      height: isWide ? 130 : 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return GestureDetector(
            onTap: () => context.push('/content-detail/${item.id}'),
            child: Container(
              width: isWide ? 220 : 120,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.surface,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: AppColors.surface),
                    errorWidget: (context, url, error) =>
                        Container(color: AppColors.surface),
                  ),
                  if (isWide)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black87],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onBackground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
