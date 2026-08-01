import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _preferredQuality = 'Auto (Max 4K)';
  bool _parentalControlActive = false;

  Future<void> _clearCache() async {
    try {
      await Hive.box<dynamic>('watchlist').clear();
      await Hive.box<dynamic>('continue_watching').clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Watch cache cleared successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear cache: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear Watch Cache?'),
        content: const Text(
          'This will delete all movies currently in your local watchlist and continue watching list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearCache();
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQualityDialog() {
    final qualities = [
      'Low (Data Saver)',
      'Medium (720p)',
      'High (1080p)',
      'Auto (Max 4K)',
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Preferred Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: qualities.map((q) {
            return RadioListTile<String>(
              title: Text(q, style: const TextStyle(color: Colors.white)),
              value: q,
              groupValue: _preferredQuality,
              activeColor: AppColors.primary,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _preferredQuality = val;
                  });
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showParentalControlsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Parental Control PIN'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set a 4-digit security PIN to restrict content modifications and block age-restricted titles.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: 'Enter 4-digit PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _parentalControlActive = !_parentalControlActive;
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _parentalControlActive
                        ? 'Parental Lock enabled.'
                        : 'Parental Lock disabled.',
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out?'),
        content: const Text(
          'Are you sure you want to sign out of your DOOM OTT account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(
                '/auth',
              ); // Route back to authentication landing screen
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Account?',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text(
          'Warning: This action is permanent. Deleting your account will remove all subscriptions, profile data, and payment logs immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/auth'); // route back to signin
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account successfully queued for deletion.'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text(
              'Delete Permanent',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _buildSectionHeader('Profile Settings'),
          _buildSettingsRow(
            icon: LucideIcons.user,
            title: 'Edit Current Profile',
            subtitle: 'Change name or avatar theme color',
            onTap: () => context.push('/edit-profile?id=p_1'),
          ),
          const Divider(color: Colors.white10),
          _buildSettingsRow(
            icon: LucideIcons.users,
            title: 'Manage Sub-profiles',
            subtitle: 'Switch, create or delete profiles',
            onTap: () => context.push('/profile-picker?manage=true'),
          ),
          const Divider(color: Colors.white10),

          _buildSectionHeader('Billing & Premium'),
          _buildSettingsRow(
            icon: LucideIcons.creditCard,
            title: 'Subscription & Billing',
            subtitle: 'Upgrade, downgrade or cancel plans',
            onTap: () => context.push('/subscription'),
          ),
          const Divider(color: Colors.white10),
          _buildSettingsRow(
            icon: LucideIcons.history,
            title: 'Payment Transactions History',
            subtitle: 'Tax invoices and receipt records',
            onTap: () => context.push('/payment-history'),
          ),
          const Divider(color: Colors.white10),

          _buildSectionHeader('Preferences'),
          _buildSettingsRow(
            icon: LucideIcons.bell,
            title: 'Notification Settings',
            subtitle: 'Push switches, email subscriptions',
            onTap: () => context.push('/notifications'),
          ),
          const Divider(color: Colors.white10),
          _buildSettingsRow(
            icon: LucideIcons.shieldAlert,
            title: 'Parental Controls Lock',
            subtitle: _parentalControlActive
                ? 'Lock is currently ACTIVE'
                : 'Setup title rating constraints',
            onTap: _showParentalControlsDialog,
          ),
          const Divider(color: Colors.white10),
          _buildSettingsRow(
            icon: LucideIcons.download,
            title: 'Download & Playback Quality',
            subtitle: _preferredQuality,
            onTap: _showQualityDialog,
          ),
          const Divider(color: Colors.white10),

          _buildSectionHeader('Storage & Support'),
          _buildSettingsRow(
            icon: LucideIcons.trash2,
            title: 'Clear Watch Cache Data',
            subtitle: 'Deletes local watchlists and history entries',
            onTap: _showClearCacheDialog,
            isError: true,
          ),
          const Divider(color: Colors.white10),

          _buildSectionHeader('Account Safety'),
          _buildSettingsRow(
            icon: LucideIcons.logOut,
            title: 'Sign Out Account',
            subtitle: 'Logout current session and switch user',
            onTap: _showLogoutConfirmation,
            isError: true,
          ),
          const Divider(color: Colors.white10),
          _buildSettingsRow(
            icon: LucideIcons.xCircle,
            title: 'Permanent Account Deletion',
            subtitle: 'Warning: This action will wipe all history',
            onTap: _showDeleteAccountConfirmation,
            isError: true,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isError = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isError ? AppColors.error : Colors.white70,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isError ? AppColors.error : Colors.white,
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
