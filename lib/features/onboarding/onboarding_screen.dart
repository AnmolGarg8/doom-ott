import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/theme/theme_data.dart';
import '../../core/widgets/primary_button.dart';
import 'widgets/aperture_iris.dart';

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
      'title': 'Straight From Our Studio',
      'description':
          'No reruns. No licensed content. Every frame here was shot, cut, and finished by our own production house.',
    },
    {
      'title': 'Feature Films, Full Length',
      'description':
          'Our movies and series, the way they were meant to be watched — no cuts, no filler, start to finish.',
    },
    {
      'title': '60 Seconds. Full Story.',
      'description':
          'Bite-sized originals built for a quick watch — stack through our short-form series whenever you\'ve got a minute.',
    },
    {
      'title': 'Yours, On Any Screen',
      'description':
          'Pick up exactly where you left off — phone, tablet, or living room, the studio travels with you.',
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Ambient Background Drifting Blobs
          const Positioned.fill(child: _AmbientBackground()),

          // 2. PageView Content
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
              final isActive = _currentPage == index;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 60.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Dynamic illustration wrapped in signature Aperture Iris Reveal
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: ApertureIris(
                        isActive: isActive,
                        child: _buildScene(index, isActive),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Display face typography for headlines
                    Text(
                      item['title']!.toUpperCase(),
                      style: AppTheme.displayFont.copyWith(
                        fontSize: 34,
                        letterSpacing: 1.5,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item['description']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          // 3. Skip Button (Top-Right)
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () => context.go('/auth'),
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // 4. Progress and Controls (Bottom Bar)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Film Slate Frame Counter indicator
                _FilmSlateFrameCounter(
                  currentPage: _currentPage,
                  totalPages: _onboardingData.length,
                ),
                const SizedBox(height: 32),

                // Control Buttons
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
                                  duration: const Duration(milliseconds: 350),
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
                            duration: const Duration(milliseconds: 350),
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

  Widget _buildScene(int index, bool isActive) {
    switch (index) {
      case 0:
        return _ClapperboardScene(isActive: isActive);
      case 1:
        return _FilmStripScene(isActive: isActive);
      case 2:
        return _PortraitStackScene(isActive: isActive);
      case 3:
        return _BroadcastWavesScene(isActive: isActive);
      default:
        return const SizedBox();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AMBIENT BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────
class _AmbientBackground extends StatefulWidget {
  const _AmbientBackground();

  @override
  State<_AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<_AmbientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final xOffset1 = math.sin(t * 2 * math.pi) * 30.0;
        final yOffset1 = math.cos(t * 2 * math.pi) * 40.0;
        final xOffset2 = math.cos(t * 2 * math.pi + math.pi) * 35.0;
        final yOffset2 = math.sin(t * 2 * math.pi + math.pi) * 30.0;

        return Stack(
          children: [
            // Blob 1: Amber Glow
            Positioned(
              left: 40 + xOffset1,
              top: 100 + yOffset1,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emberAmber.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Blob 2: Silver Glow
            Positioned(
              right: 20 + xOffset2,
              bottom: 120 + yOffset2,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.08),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILM SLATE PROGRESS INDICATOR
// ─────────────────────────────────────────────────────────────────────────────
class _FilmSlateFrameCounter extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _FilmSlateFrameCounter({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final reelText = 'REEL 0${currentPage + 1} / 0$totalPages';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mono-styled JetBrains Mono label
        Text(
          reelText,
          style: AppTheme.monoFont.copyWith(
            color: AppColors.smokeGrey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalPages, (index) {
            final isCurrent = index == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 14,
              height: isCurrent ? 6 : 3,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.emberAmber
                    : const Color(0xFF333333),
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCENE 1: CLAPPERBOARD
// ─────────────────────────────────────────────────────────────────────────────
class _ClapperboardScene extends StatefulWidget {
  final bool isActive;
  const _ClapperboardScene({required this.isActive});

  @override
  State<_ClapperboardScene> createState() => _ClapperboardSceneState();
}

class _ClapperboardSceneState extends State<_ClapperboardScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _rotationAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.4,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 1.0,
      ),
    ]).animate(_controller);

    if (widget.isActive) {
      _triggerClap();
    }
  }

  @override
  void didUpdateWidget(covariant _ClapperboardScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _triggerClap();
    } else if (!widget.isActive) {
      _controller.reset();
    }
  }

  void _triggerClap() {
    // Slight delay to sync with aperture reveal transition
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        _controller.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.inkBlack,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft radial amber glow
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.emberAmber.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Clapperboard body
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              // Animated Clapper hinge and bar
              AnimatedBuilder(
                animation: _rotationAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: const Offset(-25, 0),
                    child: Transform.rotate(
                      angle: _rotationAnim.value,
                      origin: const Offset(-45, 10),
                      child: Container(
                        width: 130,
                        height: 20,
                        decoration: const BoxDecoration(color: Colors.black),
                        child: CustomPaint(painter: _ClapperStripesPainter()),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 2),
              // Clapper base
              Container(
                width: 130,
                height: 75,
                decoration: BoxDecoration(
                  color: AppColors.inkBlack,
                  border: Border.all(color: Colors.white10),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                child: Center(
                  child: Text(
                    'DOOM OTT',
                    style: AppTheme.displayFont.copyWith(
                      color: AppColors.secondary,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClapperStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.emberAmber
      ..style = PaintingStyle.fill;

    // Draw clapper board top board diagonally striped pattern
    const stripeWidth = 12.0;
    for (double i = -stripeWidth; i < size.width; i += stripeWidth * 2) {
      final path = Path()
        ..moveTo(i, 0)
        ..lineTo(i + stripeWidth, 0)
        ..lineTo(i + stripeWidth + 10, size.height)
        ..lineTo(i + 10, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// SCENE 2: FILM STRIP
// ─────────────────────────────────────────────────────────────────────────────
class _FilmStripScene extends StatefulWidget {
  final bool isActive;
  const _FilmStripScene({required this.isActive});

  @override
  State<_FilmStripScene> createState() => _FilmStripSceneState();
}

class _FilmStripSceneState extends State<_FilmStripScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.inkBlack,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(260, 110),
              painter: _FilmStripPainter(offset: _controller.value * 120.0),
            );
          },
        ),
      ),
    );
  }
}

class _FilmStripPainter extends CustomPainter {
  final double offset;
  _FilmStripPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFF151515);
    final holePaint = Paint()..color = Colors.black;

    // Base strip rectangle background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Frame specs
    const frameWidth = 110.0;
    const frameSpacing = 10.0;
    const totalWidth = frameWidth + frameSpacing;

    // Draw horizontal looping frames
    for (int i = -1; i < 3; i++) {
      final double xPos = (i * totalWidth) - (offset % totalWidth) + 10;
      final rect = Rect.fromLTWH(xPos, 14, frameWidth, size.height - 28);

      final framePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: i % 2 == 0
              ? [
                  AppColors.emberAmber.withValues(alpha: 0.4),
                  AppColors.inkBlack,
                ]
              : [
                  AppColors.secondary.withValues(alpha: 0.4),
                  AppColors.inkBlack,
                ],
        ).createShader(rect);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        framePaint,
      );
    }

    // Sprocket holes along top and bottom
    const double sprocketSpacing = 16.0;
    for (
      double x = -sprocketSpacing;
      x < size.width + sprocketSpacing;
      x += sprocketSpacing
    ) {
      final double realX = x - (offset % sprocketSpacing);
      // Top hole
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(realX, 4, 8, 6),
          const Radius.circular(1.5),
        ),
        holePaint,
      );
      // Bottom hole
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(realX, size.height - 10, 8, 6),
          const Radius.circular(1.5),
        ),
        holePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FilmStripPainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCENE 3: PORTRAIT CARD DECK
// ─────────────────────────────────────────────────────────────────────────────
class _PortraitStackScene extends StatefulWidget {
  final bool isActive;
  const _PortraitStackScene({required this.isActive});

  @override
  State<_PortraitStackScene> createState() => _PortraitStackSceneState();
}

class _PortraitStackSceneState extends State<_PortraitStackScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.inkBlack,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value * 2 * math.pi;

            // Shift amplitudes out of phase
            final float1 = math.sin(t) * 6.0;
            final float2 = math.sin(t + 2.0) * 5.0;
            final float3 = math.sin(t + 4.0) * 6.0;

            return Stack(
              alignment: Alignment.center,
              children: [
                // Card 3: Back, rotated -8 degrees
                Transform.translate(
                  offset: Offset(-22, float3),
                  child: Transform.rotate(
                    angle: -8 * math.pi / 180,
                    child: _buildPortraitCard(
                      gradient: const [Color(0xFF333333), Color(0xFF151515)],
                    ),
                  ),
                ),
                // Card 2: Middle, rotated +8 degrees
                Transform.translate(
                  offset: Offset(22, float2),
                  child: Transform.rotate(
                    angle: 8 * math.pi / 180,
                    child: _buildPortraitCard(
                      gradient: const [Color(0xFF222222), Color(0xFF0F0F0F)],
                    ),
                  ),
                ),
                // Card 1: Front, active center
                Transform.translate(
                  offset: Offset(0, float1),
                  child: _buildPortraitCard(
                    gradient: [
                      AppColors.emberAmber.withValues(alpha: 0.85),
                      AppColors.inkBlack,
                    ],
                    hasBadge: true,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortraitCard({
    required List<Color> gradient,
    bool hasBadge = false,
  }) {
    return Container(
      width: 76,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24, width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradient,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Play indicator icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.play, size: 16, color: Colors.white),
          ),
          if (hasBadge)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.emberAmber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '60s',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCENE 4: BROADCAST WAVES
// ─────────────────────────────────────────────────────────────────────────────
class _BroadcastWavesScene extends StatefulWidget {
  final bool isActive;
  const _BroadcastWavesScene({required this.isActive});

  @override
  State<_BroadcastWavesScene> createState() => _BroadcastWavesSceneState();
}

class _BroadcastWavesSceneState extends State<_BroadcastWavesScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.inkBlack,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(260, 260),
            painter: _WavesPainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _WavesPainter extends CustomPainter {
  final double progress;
  _WavesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Draw concentric broadcast rings expanding and fading
    const numRings = 3;
    for (int i = 0; i < numRings; i++) {
      final ringProgress = (progress + (i / numRings)) % 1.0;
      final radius = 25.0 + (ringProgress * 85.0);
      final opacity = 1.0 - ringProgress;

      final ringPaint = Paint()
        ..color = AppColors.emberAmber.withValues(alpha: opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      canvas.drawCircle(center, radius, ringPaint);
    }

    // 2. Center Studio Broadcast Play icon button
    final centerPaint = Paint()..color = AppColors.emberAmber;
    canvas.drawCircle(center, 25, centerPaint);

    final path = Path()
      ..moveTo(center.dx - 4, center.dy - 7)
      ..lineTo(center.dx - 4, center.dy + 7)
      ..lineTo(center.dx + 7, center.dy)
      ..close();

    final playPaint = Paint()..color = Colors.black;
    canvas.drawPath(path, playPaint);
  }

  @override
  bool shouldRepaint(covariant _WavesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
