import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Legal & Help'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildFAQTile(
              question: 'How do I download movies offline?',
              answer:
                  'Subscribing to the Premium or VIP tiers unlocks offline caching. When active, a download icon will appear on all details screens.',
            ),
            _buildFAQTile(
              question: 'Which devices are supported?',
              answer:
                  'DOOM OTT is currently compatible with Android (version 8.0+) and iOS (version 15.0+). Desktop and Web clients are coming soon.',
            ),
            _buildFAQTile(
              question: 'How does local caching work?',
              answer:
                  'Your watchlist and watch history are securely cached using a lightning-fast key-value database (Hive) right on your device. Clearing settings cache will purge this list.',
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'By accessing DOOM OTT, you agree to bound by these terms of service, all applicable laws and regulations, and agree that you are responsible for compliance with any applicable local laws. The materials contained in this website are protected by applicable copyright and trademark law.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your privacy is important to us. It is DOOM OTT\'s policy to respect your privacy regarding any information we may collect from you across our application. We only request personal information when we truly need it to provide a service to you. We collect it by fair and lawful means, with your knowledge and consent.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Text(
              answer,
              style: const TextStyle(
                color: AppColors.muted,
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
