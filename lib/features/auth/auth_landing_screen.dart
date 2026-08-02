import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/theme/theme_data.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../onboarding/widgets/aperture_iris.dart';

class AuthLandingScreen extends StatefulWidget {
  const AuthLandingScreen({super.key});

  @override
  State<AuthLandingScreen> createState() => _AuthLandingScreenState();
}

class _AuthLandingScreenState extends State<AuthLandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeScale;
  late List<Animation<double>> _buttonAnims;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    // 1. Logo scale and fade animation
    _logoFadeScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );

    // 2. Staggered buttons slide and fade animations
    _buttonAnims = List.generate(4, (index) {
      final start = 0.3 + (index * 0.12);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background atmospheric drifting blobs
          const Positioned.fill(child: _AmbientAuthBackground()),

          // Main content tree
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 3),

                  // Brand Anchor: Logo + Subtitles + Aperture framework
                  AnimatedBuilder(
                    animation: _logoFadeScale,
                    builder: (context, child) {
                      final val = _logoFadeScale.value;
                      return Opacity(
                        opacity: val,
                        child: Transform.scale(
                          scale: 0.9 + (val * 0.1),
                          child: child,
                        ),
                      );
                    },
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Atmospheric fully-open Aperture Iris as background framing device
                          Opacity(
                            opacity: 0.12,
                            child: SizedBox(
                              width: 320,
                              height: 320,
                              child: IgnorePointer(
                                child: ApertureIris(
                                  isActive: true,
                                  child: Container(),
                                ),
                              ),
                            ),
                          ),
                          // Branding Details
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'DOOM',
                                style: AppTheme.displayFont.copyWith(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 8,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'STREAM DESTINY',
                                style: AppTheme.monoFont.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.smokeGrey,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Phone login button
                  _buildAnimatedWrapper(
                    index: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: PrimaryButton(
                        label: 'Continue with Phone',
                        onPressed: () {
                          context.push('/auth/phone');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppThemeConstants.space16),

                  // Email login button
                  _buildAnimatedWrapper(
                    index: 1,
                    child: SecondaryButton(
                      label: 'Continue with Email',
                      onPressed: () {
                        context.push('/auth/email');
                      },
                    ),
                  ),
                  const SizedBox(height: AppThemeConstants.space24),

                  // Divider "or"
                  _buildAnimatedWrapper(
                    index: 2,
                    child: Row(
                      children: [
                        const Expanded(child: _GradientLine(isLeft: true)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: AppColors.smokeGrey,
                              fontSize: 14,
                              fontFamily: AppTheme.monoFont.fontFamily,
                            ),
                          ),
                        ),
                        const Expanded(child: _GradientLine(isLeft: false)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppThemeConstants.space24),

                  // Social Sign-ins
                  _buildAnimatedWrapper(
                    index: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialIconButton(
                          icon: LucideIcons.chrome,
                          onPressed: () {
                            context.push('/auth/email');
                          },
                        ),
                        const SizedBox(width: 28),
                        _SocialIconButton(
                          icon: LucideIcons.apple,
                          onPressed: () {
                            context.push('/auth/email');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedWrapper({required int index, required Widget child}) {
    final anim = _buttonAnims[index];
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final val = anim.value;
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, 16 * (1.0 - val)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRADIENT SEPARATOR LINES
// ─────────────────────────────────────────────────────────────────────────────
class _GradientLine extends StatelessWidget {
  final bool isLeft;
  const _GradientLine({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLeft
              ? const [Colors.transparent, AppColors.smokeGrey]
              : const [AppColors.smokeGrey, Colors.transparent],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AMBIENT DRIFTING BLOBS
// ─────────────────────────────────────────────────────────────────────────────
class _AmbientAuthBackground extends StatefulWidget {
  const _AmbientAuthBackground();

  @override
  State<_AmbientAuthBackground> createState() => _AmbientAuthBackgroundState();
}

class _AmbientAuthBackgroundState extends State<_AmbientAuthBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
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
        final x1 = math.sin(t * 2 * math.pi) * 35.0;
        final y1 = math.cos(t * 2 * math.pi) * 45.0;
        final x2 = math.cos(t * 2 * math.pi + math.pi) * 40.0;
        final y2 = math.sin(t * 2 * math.pi + math.pi) * 35.0;

        return Stack(
          children: [
            // Blob 1: Amber Glow
            Positioned(
              left: 20 + x1,
              top: 150 + y1,
              child: Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emberAmber.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Blob 2: Silver Glow
            Positioned(
              right: 10 + x2,
              bottom: 180 + y2,
              child: Container(
                width: 300,
                height: 300,
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
// TACTILE SOCIAL ICON BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _SocialIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialIconButton({required this.icon, required this.onPressed});

  @override
  State<_SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<_SocialIconButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1.5),
            color: Colors.black38,
          ),
          child: Center(
            child: Icon(widget.icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
