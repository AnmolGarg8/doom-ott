import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Unlimited Movies & Shows',
      'description':
          'Watch thousands of blockbusters, TV series, anime, and documentaries in glorious 4K resolution.',
      'icon': LucideIcons.playCircle,
      'color': Colors.redAccent,
    },
    {
      'title': 'Watch Anywhere, Anytime',
      'description':
          'Stream effortlessly on your phone, tablet, laptop, or TV without any buffering or limits.',
      'icon': LucideIcons.smartphone,
      'color': Colors.blueAccent,
    },
    {
      'title': "Original Content You Won't Find Elsewhere",
      'description':
          'Enjoy exclusive productions, creator shows, and cinematic originals available only on Doom.',
      'icon': LucideIcons.award,
      'color': Colors.amberAccent,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background: #000000
      body: Stack(
        children: [
          // Swipeable Pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              final item = _onboardingData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 80.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Placeholder illustration container
                    // TODO: Swap in final client-provided graphic/illustration assets here
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppThemeConstants.radiusCard,
                        ),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Center(
                        child: Icon(
                          item['icon'] as IconData,
                          size: 72,
                          color: item['color'] as Color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      item['title']!,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item['description']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          // Skip Button in top-right
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () => context.go('/auth'),
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.secondary, // #C0C0C0
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Bottom Bar containing indicators and actions
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Indicators Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : AppColors.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Button controls
                if (_currentPage == _onboardingData.length - 1)
                  PrimaryButton(
                    label: 'Get Started',
                    onPressed: () {
                      context.go('/auth');
                    },
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Text Button
                      TextButton(
                        onPressed: _currentPage == 0
                            ? null
                            : () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: _currentPage == 0
                                ? Colors.transparent
                                : AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Next Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppThemeConstants.radiusButton,
                            ),
                          ),
                        ),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
