import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../home/bloc/content_bloc.dart';
import '../home/bloc/content_event.dart';
import '../home/bloc/content_state.dart';
import '../../core/theme/colors.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final List<String> _genres = [
    'Action',
    'Sci-Fi',
    'Fantasy',
    'Comedy',
    'Drama',
    'Adventure',
    'Mystery',
    'Thriller',
  ];
  String _selectedGenre = 'Action';

  @override
  void initState() {
    super.initState();
    context.read<ContentBloc>().add(LoadGenreContent(_selectedGenre));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Browse Genres'), centerTitle: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genre select row
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = genre == _selectedGenre;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedGenre = genre;
                        });
                        context.read<ContentBloc>().add(
                          LoadGenreContent(genre),
                        );
                      }
                    },
                    selectedColor: AppColors.primary,
                    checkmarkColor: AppColors.background,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.background
                          : AppColors.onBackground,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF1F1F1F),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Content display grid
          Expanded(
            child: BlocBuilder<ContentBloc, ContentState>(
              builder: (context, state) {
                if (state is ContentLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                } else if (state is GenreContentLoaded) {
                  if (state.content.isEmpty) {
                    return const Center(
                      child: Text(
                        'No content found in this genre.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2 / 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: state.content.length,
                    itemBuilder: (context, index) {
                      final item = state.content[index];
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
                      'Error loading genre: ${state.message}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
