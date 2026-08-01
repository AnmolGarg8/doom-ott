import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Terms & Conditions',
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

            // TODO: Replace this placeholder legal draft with client-provided terms document
            const Text(
              'Welcome to DOOM OTT! By accessing or using our streaming application, you agree to comply with and be bound by these Terms and Conditions. Please review them carefully.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('1. License Agreement'),
            const Text(
              'Permission is granted to temporarily stream the materials (information or video content) on DOOM OTT\'s application for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license, you may not modify or copy the materials, use them for commercial display, or attempt to decompile any software contained in the app.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('2. Subscription & Payments'),
            const Text(
              'Some parts of the Service are billed on a subscription basis. You will be billed in advance on a recurring and periodic cycle. Billing cycles are set either on a monthly, quarterly, or annual basis. Subscriptions automatically renew unless cancelled by you or DOOM OTT.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('3. User Accounts'),
            const Text(
              'When you create an account with us, you must provide us information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service. You are responsible for safeguarding your security credentials.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('4. Content Limitations'),
            const Text(
              'Maturity ratings (G, PG, PG-13, 18+) are assigned to all streaming titles. We provide parental locks and PIN settings to filter content. Parents or guardians are responsible for supervising children under the age of 18 while using our application.',
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
