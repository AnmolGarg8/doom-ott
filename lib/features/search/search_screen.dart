import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../home/bloc/content_bloc.dart';
import '../home/bloc/content_event.dart';
import '../home/bloc/content_state.dart';
import '../../core/theme/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<ContentBloc>().add(SearchContentRequested(query.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: AppColors.onBackground),
          decoration: InputDecoration(
            hintText: 'Search movies, shows, genres...',
            prefixIcon: const Icon(LucideIcons.search, color: AppColors.muted),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.muted),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: BlocBuilder<ContentBloc, ContentState>(
        builder: (context, state) {
          if (_searchController.text.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.search, size: 64, color: AppColors.muted),
                  SizedBox(height: 16),
                  Text(
                    'Search for your favorites',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find movies, TV series, actors, and genres.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          if (state is ContentLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is SearchResultsLoaded) {
            if (state.results.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.frown, size: 64, color: AppColors.muted),
                    SizedBox(height: 16),
                    Text(
                      'No results found',
                      style: TextStyle(color: AppColors.muted, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try different keywords or genres.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: state.results.length,
              itemBuilder: (context, index) {
                final item = state.results[index];
                return GestureDetector(
                  onTap: () => context.push('/content-detail/${item.id}'),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.surface,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: item.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: AppColors.surface),
                      errorWidget: (context, url, error) =>
                          Container(color: AppColors.surface),
                    ),
                  ),
                );
              },
            );
          } else if (state is ContentError) {
            return Center(
              child: Text(
                'Search failed: ${state.message}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
