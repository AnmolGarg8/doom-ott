import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

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
          'Legal & Help',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'Select an option to view customer support resources, company profiles, or service terms.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),

          _buildRow(
            icon: LucideIcons.helpCircle,
            title: 'Help & FAQ',
            subtitle: 'Frequently asked questions, support contacts',
            onTap: () => context.push('/help-faq'),
          ),
          const Divider(color: Colors.white10),
          _buildRow(
            icon: LucideIcons.shieldCheck,
            title: 'Privacy Policy',
            subtitle: 'Data usage guidelines and collection rules',
            onTap: () => context.push('/privacy-policy'),
          ),
          const Divider(color: Colors.white10),
          _buildRow(
            icon: LucideIcons.fileText,
            title: 'Terms & Conditions',
            subtitle: 'User license agreements and subscription terms',
            onTap: () => context.push('/terms-conditions'),
          ),
          const Divider(color: Colors.white10),
          _buildRow(
            icon: LucideIcons.globe,
            title: 'About Us',
            subtitle: 'DOOM OTT company profile and social media',
            onTap: () => context.push('/about-us'),
          ),
          const Divider(color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
      ),
      trailing: const Icon(
        LucideIcons.chevronRight,
        color: AppColors.muted,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
