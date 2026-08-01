import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/widgets/primary_button.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How do I download movies offline?',
      'answer':
          'Subscribing to the Quarterly Premium or Annual Ultimate tiers unlocks offline video downloads. When active, a download icon will appear next to episodes and movie summaries.',
    },
    {
      'question': 'Which devices are supported?',
      'answer':
          'DOOM OTT is currently compatible with Android (version 8.0+) and iOS (version 15.0+). Support for Android TV, Apple TV, Firestick, and Web browsers is planned for release in late 2026.',
    },
    {
      'question': 'Can I share my account with family members?',
      'answer':
          'Yes! You can create up to 4 sub-profiles per account. Simultaneous streaming limit ranges from 1 to 4 screens depending on your active subscription plan tier.',
    },
    {
      'question': 'How do I cancel my subscription?',
      'answer':
          'You can manage or cancel your subscription anytime via Account Settings > Subscription & Billing. Cancellations take effect at the end of the current billing period.',
    },
    {
      'question': 'What are parental lock pin settings?',
      'answer':
          'Parental controls allow you to lock specific sub-profiles with a 4-digit PIN and filter content visibility based on maturity ratings (G, PG, PG-13, 18+) or genres.',
    },
  ];

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
          'Help & FAQ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Have questions? We\'re here to help you get the best streaming experience.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // FAQ Expansion Tiles
            ..._faqs.map(
              (faq) => _buildFAQTile(faq['question']!, faq['answer']!),
            ),
            const SizedBox(height: 32),

            // Contact Us Block
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1F1F1F)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Still need help?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Our support team is available 24/7 to resolve billing, playback, or account issues.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Email Button
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Opening mail app... support@doomott.com',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.mail, size: 16),
                          label: const Text(
                            'Email Us',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Live Chat Mock Button
                      // TODO: Integrate real live chat widget (e.g. Zendesk, Freshchat SDK) in this callback
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Live Chat is currently offline. Please try emailing us.',
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.messageSquare, size: 16),
                          label: const Text(
                            'Live Chat',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: Colors.white70,
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
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
