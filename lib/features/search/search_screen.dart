import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/widgets/content_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/content_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Search/Filter states
  String _query = '';
  bool _isLoading = false;
  List<ContentModel> _searchResults = [];

  // Filter Bottom Sheet selections
  Set<String> _selectedGenres = {};
  String? _selectedLanguage;
  RangeValues _yearRange = const RangeValues(2020, 2026);
  double _minRatingIndex = 0.0; // 0: All, 1: PG, 2: PG-13, 3: 16+, 4: 18+

  final List<String> _trendingSearches = [
    'Doom',
    'Velocity',
    'Tears of Steel',
    'Sintel',
    'Cosmic',
  ];

  final List<String> _allGenres = [
    'Action',
    'Drama',
    'Comedy',
    'Sci-Fi',
    'Originals',
  ];
  final List<String> _languages = ['English', 'Spanish', 'Hindi', 'Korean'];
  final List<String> _ratingLevels = ['All', 'PG', 'PG-13', '16+', '18+'];

  @override
  void initState() {
    super.initState();
    _applyFilters(initial: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _query = value.trim();
      });
      _applyFilters();
    });
  }

  Future<void> _applyFilters({bool initial = false}) async {
    if (!initial) {
      setState(() {
        _isLoading = true;
      });
      // Simulate API latency delay
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (!mounted) return;

    List<ContentModel> results = MockData.allContent;

    // 1. Text Query Filter
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      results = results
          .where(
            (item) =>
                item.title.toLowerCase().contains(q) ||
                item.synopsis.toLowerCase().contains(q),
          )
          .toList();
    }

    // 2. Genre Multi-select Filter
    if (_selectedGenres.isNotEmpty) {
      results = results
          .where((item) => item.genre.any((g) => _selectedGenres.contains(g)))
          .toList();
    }

    // 3. Language Filter (Mock Implementation: odd IDs Spanish, even IDs Hindi/Korean, others English)
    if (_selectedLanguage != null) {
      results = results.where((item) {
        final idNum = int.tryParse(item.id) ?? 0;
        String itemLang = 'English';
        if (idNum % 4 == 1) itemLang = 'Spanish';
        if (idNum % 4 == 2) itemLang = 'Hindi';
        if (idNum % 4 == 3) itemLang = 'Korean';
        return itemLang == _selectedLanguage;
      }).toList();
    }

    // 4. Release Year Range Filter
    results = results.where((item) {
      final year = int.tryParse(item.releaseYear) ?? 2024;
      return year >= _yearRange.start.round() && year <= _yearRange.end.round();
    }).toList();

    // 5. Rating Index Filter
    if (_minRatingIndex > 0) {
      final minRating = _ratingLevels[_minRatingIndex.round()];
      results = results.where((item) {
        final itemIndex = _getRatingPriority(item.rating);
        final minIndex = _getRatingPriority(minRating);
        return itemIndex >= minIndex;
      }).toList();
    }

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  int _getRatingPriority(String rating) {
    switch (rating.toUpperCase()) {
      case 'ALL':
      case 'G':
        return 0;
      case 'PG':
        return 1;
      case 'PG-13':
      case '13+':
        return 2;
      case '16+':
        return 3;
      case '18+':
      case 'R':
        return 4;
      default:
        return 0;
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedGenres.clear();
      _selectedLanguage = null;
      _yearRange = const RangeValues(2020, 2026);
      _minRatingIndex = 0.0;
    });
    _applyFilters();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Content',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedGenres.clear();
                            _selectedLanguage = null;
                            _yearRange = const RangeValues(2020, 2026);
                            _minRatingIndex = 0.0;
                          });
                          _clearFilters();
                        },
                        child: const Text(
                          'Reset All',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),

                  // Genres Multi-select
                  const Text(
                    'Genres',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allGenres.map((g) {
                      final isSelected = _selectedGenres.contains(g);
                      return FilterChip(
                        label: Text(g),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white10,
                        checkmarkColor: Colors.black,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              _selectedGenres.add(g);
                            } else {
                              _selectedGenres.remove(g);
                            }
                          });
                          _applyFilters();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Language Choice
                  const Text(
                    'Language',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _languages.map((l) {
                      final isSelected = _selectedLanguage == l;
                      return ChoiceChip(
                        label: Text(l),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white10,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedLanguage = selected ? l : null;
                          });
                          _applyFilters();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Release Year Range
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Release Year',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_yearRange.start.round()} - ${_yearRange.end.round()}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _yearRange,
                    min: 2020,
                    max: 2026,
                    divisions: 6,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white10,
                    onChanged: (values) {
                      setModalState(() {
                        _yearRange = values;
                      });
                      _applyFilters();
                    },
                  ),
                  const SizedBox(height: 24),

                  // Minimum Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Minimum Rating Constraint',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _ratingLevels[_minRatingIndex.round()],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _minRatingIndex,
                    min: 0,
                    max: 4,
                    divisions: 4,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white10,
                    onChanged: (val) {
                      setModalState(() {
                        _minRatingIndex = val;
                      });
                      _applyFilters();
                    },
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final showTrending =
        _query.isEmpty &&
        _selectedGenres.isEmpty &&
        _selectedLanguage == null &&
        _yearRange.start == 2020 &&
        _yearRange.end == 2026 &&
        _minRatingIndex == 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search input field + filter button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search movies, shows...',
                        prefixIcon: const Icon(
                          LucideIcons.search,
                          color: AppColors.muted,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  LucideIcons.x,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter button
                  IconButton(
                    icon: Icon(
                      LucideIcons.sliders,
                      color:
                          (_selectedGenres.isNotEmpty ||
                              _selectedLanguage != null ||
                              _minRatingIndex > 0 ||
                              _yearRange.start > 2020 ||
                              _yearRange.end < 2026)
                          ? AppColors.primary
                          : Colors.white,
                    ),
                    onPressed: _showFilterBottomSheet,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Trending Searches Section
              if (showTrending) ...[
                const Text(
                  'Trending Searches',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _trendingSearches.map((term) {
                    return ActionChip(
                      label: Text(term),
                      backgroundColor: AppColors.surface,
                      labelStyle: const TextStyle(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppThemeConstants.radiusChip,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _query = term;
                          _searchController.text = term;
                        });
                        _applyFilters();
                      },
                    );
                  }).toList(),
                ),
              ],

              // Scannable search results
              if (!showTrending)
                Expanded(
                  child: _isLoading
                      ? ListView.builder(
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  const LoadingShimmer(
                                    width: 70,
                                    height: 100,
                                    borderRadius:
                                        AppThemeConstants.radiusButton,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const LoadingShimmer(
                                          width: 160,
                                          height: 16,
                                        ),
                                        const SizedBox(height: 8),
                                        const LoadingShimmer(
                                          width: 100,
                                          height: 12,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const LoadingShimmer(
                                              width: 40,
                                              height: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            const LoadingShimmer(
                                              width: 60,
                                              height: 12,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : _searchResults.isEmpty
                      ? const EmptyState(
                          icon: LucideIcons.frown,
                          title: 'No Matches Found',
                          description:
                              'We couldn\'t find any titles fitting these criteria. Try adjusting your query or resetting filters.',
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            return _buildSearchResultRow(_searchResults[index]);
                          },
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultRow(ContentModel item) {
    return GestureDetector(
      onTap: () => context.push('/content-detail/${item.id}'),
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
            // Poster thumbnail (aspect 2/3)
            Container(
              width: 70,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AppThemeConstants.radiusButton,
                ),
                image: DecorationImage(
                  image: NetworkImage(item.posterUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.genre.join(', '),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Rating Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.rating,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.durationMinutes} mins',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
