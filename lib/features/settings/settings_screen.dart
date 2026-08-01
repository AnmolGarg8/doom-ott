import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearCache(BuildContext context) async {
    try {
      await Hive.box<dynamic>('watchlist').clear();
      await Hive.box<dynamic>('continue_watching').clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear cache: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        children: [
          _buildSectionHeader('Storage & Cache'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.trash2, color: AppColors.error),
            title: const Text(
              'Clear Watch Cache',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Remove all stored watchlist and history items',
              style: TextStyle(color: AppColors.muted),
            ),
            onTap: () => _showClearCacheDialog(context),
          ),
          const Divider(),

          _buildSectionHeader('Video Quality'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.sliders),
            title: const Text('Preferred Quality'),
            trailing: const Text(
              'Auto (Max 4K)',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          const Divider(),

          _buildSectionHeader('App Info'),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(LucideIcons.info),
            title: Text('Version'),
            trailing: Text(
              '1.0.0 (Build 1)',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(LucideIcons.globe),
            title: Text('Locale'),
            trailing: Text('en-IN', style: TextStyle(color: AppColors.muted)),
          ),
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear Cache?'),
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
              _clearCache(context);
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
}
