import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';

class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Branding / Logo
              const Center(
                child: Column(
                  children: [
                    Text(
                      'DOOM',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary, // #FFB300
                        letterSpacing: 6,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'STREAM DESTINY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Phone login button
              PrimaryButton(
                label: 'Continue with Phone',
                onPressed: () {
                  context.push('/auth/phone');
                },
              ),
              const SizedBox(height: AppThemeConstants.space16),

              // Email login button
              SecondaryButton(
                label: 'Continue with Email',
                onPressed: () {
                  context.push('/auth/email');
                },
              ),
              const SizedBox(height: AppThemeConstants.space24),

              // Divider "or"
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white10, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'or',
                      style: TextStyle(color: AppColors.muted, fontSize: 14),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white10, thickness: 1)),
                ],
              ),
              const SizedBox(height: AppThemeConstants.space24),

              // Social Sign-ins
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google sign-in
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                    ),
                    onPressed: () {
                      // Guest login mockup via Social
                      context.push('/auth/email');
                    },
                    child: const Icon(
                      LucideIcons.chrome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Apple sign-in
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                    ),
                    onPressed: () {
                      // Guest login mockup via Social
                      context.push('/auth/email');
                    },
                    child: const Icon(
                      LucideIcons.apple,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
