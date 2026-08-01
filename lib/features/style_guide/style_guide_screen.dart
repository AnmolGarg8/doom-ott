import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/content_card.dart';
import '../../core/widgets/content_carousel.dart';
import '../../core/widgets/rating_badge.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/mock/mock_data.dart';

class StyleGuideScreen extends StatefulWidget {
  const StyleGuideScreen({super.key});

  @override
  State<StyleGuideScreen> createState() => _StyleGuideScreenState();
}

class _StyleGuideScreenState extends State<StyleGuideScreen> {
  int _currentNavIndex = 0;
  bool _primaryBtnLoading = false;

  @override
  Widget build(BuildContext context) {
    final mockContent = MockData.allContent.take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Style Guide App Bar
              const CustomAppBar(backgroundOpacity: 1.0),

              Padding(
                padding: const EdgeInsets.all(AppThemeConstants.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DOOM DESIGN SYSTEM',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppThemeConstants.space8),
                    const Text(
                      'Visual QA Guide for Doom OTT typography scale, spacing grids, and component catalog.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: AppThemeConstants.space24),
                    const Divider(),

                    // 1. Typography
                    _buildSectionTitle('1. Typography Scale'),
                    _buildTextDemo(
                      context,
                      'displayLarge (Poppins)',
                      Theme.of(context).textTheme.displayLarge,
                    ),
                    _buildTextDemo(
                      context,
                      'headlineMedium (Poppins)',
                      Theme.of(context).textTheme.headlineMedium,
                    ),
                    _buildTextDemo(
                      context,
                      'titleLarge (Poppins)',
                      Theme.of(context).textTheme.titleLarge,
                    ),
                    _buildTextDemo(
                      context,
                      'bodyLarge (Inter)',
                      Theme.of(context).textTheme.bodyLarge,
                    ),
                    _buildTextDemo(
                      context,
                      'bodyMedium (Inter)',
                      Theme.of(context).textTheme.bodyMedium,
                    ),
                    _buildTextDemo(
                      context,
                      'labelSmall (Inter)',
                      Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: AppThemeConstants.space24),
                    const Divider(),

                    // 2. Spacing
                    _buildSectionTitle('2. Spacing constants'),
                    Row(
                      children: [
                        _buildSpaceGrid('S4', AppThemeConstants.space4),
                        _buildSpaceGrid('S8', AppThemeConstants.space8),
                        _buildSpaceGrid('S16', AppThemeConstants.space16),
                        _buildSpaceGrid('S24', AppThemeConstants.space24),
                        _buildSpaceGrid('S32', AppThemeConstants.space32),
                      ],
                    ),
                    const SizedBox(height: AppThemeConstants.space24),
                    const Divider(),

                    // 3. Buttons
                    _buildSectionTitle('3. Buttons'),
                    const Text(
                      'Primary Button (Normal)',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: AppThemeConstants.space8),
                    PrimaryButton(label: 'Primary Action', onPressed: () {}),
                    const SizedBox(height: AppThemeConstants.space16),
                    const Text(
                      'Primary Button (Interactive Loading Toggle)',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: AppThemeConstants.space8),
                    PrimaryButton(
                      label: 'Click to Load',
                      isLoading: _primaryBtnLoading,
                      onPressed: () {
                        setState(() {
                          _primaryBtnLoading = true;
                        });
                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) {
                            setState(() {
                              _primaryBtnLoading = false;
                            });
                          }
                        });
                      },
                    ),
                    const SizedBox(height: AppThemeConstants.space16),
                    const Text(
                      'Secondary Button',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: AppThemeConstants.space8),
                    SecondaryButton(
                      label: 'Secondary Action',
                      onPressed: () {},
                    ),
                    const SizedBox(height: AppThemeConstants.space24),
                    const Divider(),

                    // 4. Rating Badges & Shimmer
                    _buildSectionTitle('4. Badges & Loader Shimmer'),
                    Row(
                      children: [
                        const RatingBadge(rating: 8.7),
                        const SizedBox(width: AppThemeConstants.space16),
                        const RatingBadge(rating: 4.5),
                        const SizedBox(width: AppThemeConstants.space16),
                        LoadingShimmer(
                          width: 80,
                          height: 24,
                          borderRadius: AppThemeConstants.radiusChip,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppThemeConstants.space24),
                    const Divider(),

                    // 5. Content Card
                    _buildSectionTitle('5. Content Card'),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Loaded Card',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: AppThemeConstants.space8),
                              ContentCard(
                                content: mockContent.isNotEmpty
                                    ? mockContent.first
                                    : null,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppThemeConstants.space16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shimmer Card',
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(height: AppThemeConstants.space8),
                              ContentCard(isLoading: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppThemeConstants.space24),
                    const Divider(),
                  ],
                ),
              ),

              // 6. Carousels
              _buildSectionTitle('6. Content Carousel'),
              ContentCarousel(
                title: 'Featured Carousel',
                items: mockContent,
                onItemTap: (item) {},
                onSeeAllTap: () {},
              ),
              const SizedBox(height: AppThemeConstants.space8),
              ContentCarousel(
                title: 'Loading Shimmer Carousel',
                items: const [],
                isLoading: true,
                onItemTap: (item) {},
              ),
              const SizedBox(height: AppThemeConstants.space24),
              const Divider(),

              // 7. Empty State
              _buildSectionTitle('7. Empty State'),
              EmptyState(
                icon: LucideIcons.archive,
                title: 'No Live TV Stream Active',
                description:
                    'Please purchase a VIP premium pass or check back later to access live streaming sports and movies.',
                actionLabel: 'Upgrade Tier',
                onActionPressed: () {},
              ),
              const SizedBox(height: AppThemeConstants.space24),
              const Divider(),

              // 8. Navigation bar
              _buildSectionTitle('8. Bottom Navigation Bar'),
              BottomNavBar(
                currentIndex: _currentNavIndex,
                onTap: (index) {
                  setState(() {
                    _currentNavIndex = index;
                  });
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppThemeConstants.space16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTextDemo(BuildContext context, String name, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppThemeConstants.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 2),
          Text('Doom Stream Destiny', style: style),
        ],
      ),
    );
  }

  Widget _buildSpaceGrid(String label, double val) {
    return Container(
      margin: const EdgeInsets.only(right: AppThemeConstants.space8),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            '${val.toInt()}px',
            style: const TextStyle(color: AppColors.muted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
