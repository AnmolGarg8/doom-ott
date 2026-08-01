import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

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
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Last Updated: August 1, 2026',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // TODO: Replace this placeholder legal draft with client-provided policy document
            const Text(
              'Your privacy is important to us. It is DOOM OTT\'s policy to respect your privacy regarding any information we may collect from you across our application and other sites we own and operate.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('1. Information We Collect'),
            const Text(
              'We only ask for personal information when we truly need it to provide a service to you (such as your telephone number for OTP verification, or profile nicknames). We collect it by fair and lawful means, with your knowledge and consent. We also let you know why we\'re collecting it and how it will be used.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('2. Data Retention'),
            const Text(
              'We only retain collected information for as long as necessary to provide you with your requested service. What data we store, we will protect within commercially acceptable means to prevent loss and theft, as well as unauthorized access, disclosure, copying, use, or modification.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('3. Sharing of Information'),
            const Text(
              'We do not share any personally identifying information publicly or with third-parties, except when required to by law. Our app may link to external sites that are not operated by us. Please be aware that we have no control over the content and practices of these sites, and cannot accept responsibility or liability for their respective privacy policies.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('4. Cookies & Cache'),
            const Text(
              'DOOM OTT uses local database key-value storage (Hive) to save your watchlist preferences, profile information, and watch progress. This data remains on your local device and is never shared or exported without active user consent.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
