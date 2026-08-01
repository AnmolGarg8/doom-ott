import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'About Us',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),

            // Large Gold Brand Wordmark
            const Center(
              child: Column(
                children: [
                  Text(
                    'DOOM OTT',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'THE ULTIMATE STREAMING BREACH',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Company Description
            // TODO: Swap out placeholder write-up for final copy approved by the client marketing team
            const Text(
              'DOOM OTT is a next-generation video-on-demand streaming platform designed for action, sci-fi, and premium cinematic enthusiasts. Launched in 2026, we deliver high-fidelity, buffer-free streams of blockbusters, series, and exclusive Originals worldwide.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Built on a solid, offline-first client architecture using Flutter, Hive caching, and MediaKit video playback, our mission is to provide visual excellence and fluid user interactions across all mobile and television platforms.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Social Media Link Rows
            const Text(
              'Follow Us',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(context, LucideIcons.facebook, 'Facebook'),
                const SizedBox(width: 24),
                _buildSocialIcon(context, LucideIcons.twitter, 'Twitter / X'),
                const SizedBox(width: 24),
                _buildSocialIcon(context, LucideIcons.instagram, 'Instagram'),
                const SizedBox(width: 24),
                _buildSocialIcon(context, LucideIcons.youtube, 'YouTube'),
              ],
            ),
            const SizedBox(height: 60),

            // Version Log Footer
            const Center(
              child: Text(
                'Version 1.0.0 (Build 1)\n© 2026 DOOM OTT Inc. All rights reserved.',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 11,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(
    BuildContext context,
    IconData icon,
    String platformName,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70, size: 20),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening $platformName link...'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}
