import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/widgets/content_card.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/content_model.dart';

class BrowseScreen extends StatefulWidget {
  final String? initialGenre;
  const BrowseScreen({super.key, this.initialGenre});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final List<String> _genres = [
    'Action',
    'Drama',
    'Comedy',
    'Thriller',
    'Romance',
    'Documentary',
    'Kids',
    'Originals',
  ];

  late String _selectedGenre;
  bool _isLoading = false;
  List<ContentModel> _filteredContent = [];
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _selectedGenre = widget.initialGenre ?? 'Action';
    _applyFilter(initial: true);
  }

  Future<void> _applyFilter({bool initial = false}) async {
    if (!initial) {
      setState(() {
        _isLoading = true;
        _opacity = 0.0;
      });
      // Simulate API latency delay
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (!mounted) return;

    final results = MockData.allContent
        .where((element) => element.genre.contains(_selectedGenre))
        .toList();

    setState(() {
      _filteredContent = results;
      _isLoading = false;
      _opacity = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 3 : 2;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Browse Categories',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Genre Chips Row (Horizontal Scroll)
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = genre == _selectedGenre;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(genre),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    checkmarkColor: Colors.black,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppThemeConstants.radiusChip),
                    ),
                    onSelected: (selected) {
                      if (selected && genre != _selectedGenre) {
                        setState(() {
                          _selectedGenre = genre;
                        });
                        _applyFilter();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Content Grid or Loading Shimmer
          Expanded(
            child: _isLoading
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 2 / 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => const LoadingShimmer(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: AppThemeConstants.radiusCard,
                    ),
                  )
                : AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(milliseconds: 300),
                    child: _filteredContent.isEmpty
                        ? const Center(
                            child: Text(
                              'No content found for this genre.',
                              style: TextStyle(color: AppColors.muted),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 2 / 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _filteredContent.length,
                            itemBuilder: (context, index) {
                              final item = _filteredContent[index];
                              return ContentCard(
                                content: item,
                                onTap: () => context.push('/content-detail/${item.id}'),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
