import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';

class NotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final String timestamp;
  final bool isUnread;

  const NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isUnread = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Preferences States
  bool _pushNotifications = true;
  bool _emailAlerts = false;
  bool _newContentAlerts = true;
  bool _promotionalAlerts = true;

  final List<NotificationItem> _notifications = const [
    NotificationItem(
      icon: LucideIcons.clapperboard,
      title: 'New Episode Available',
      message:
          'Episode 5 of "Breach Frontiers" is now streaming in Ultra HD. Click to stream now.',
      timestamp: '2 hours ago',
      isUnread: true,
    ),
    NotificationItem(
      icon: LucideIcons.alertTriangle,
      title: 'Subscription Expiring Soon',
      message:
          'Your Monthly Basic plan expires in 3 days. Renew now to continue ad-free streaming.',
      timestamp: '1 day ago',
      isUnread: true,
    ),
    NotificationItem(
      icon: LucideIcons.badgeCheck,
      title: 'Payment Successful',
      message:
          'Thank you! We received your payment of ₹199.00 for Monthly Basic auto-renewal.',
      timestamp: '3 days ago',
    ),
    NotificationItem(
      icon: LucideIcons.sparkles,
      title: 'New Content Alert',
      message:
          'The sci-fi blockbuster "Sintel" is trending today. Add it to your watchlist!',
      timestamp: '5 days ago',
    ),
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
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Preferences switches card block
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1F1F1F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Notification Preferences',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPreferenceSwitch(
                      'Push Notifications',
                      'Real-time mobile alerts',
                      _pushNotifications,
                      (v) {
                        setState(() => _pushNotifications = v);
                      },
                    ),
                    const Divider(color: Colors.white10),
                    _buildPreferenceSwitch(
                      'Email Notifications',
                      'Newsletters, receipts, invoices',
                      _emailAlerts,
                      (v) {
                        setState(() => _emailAlerts = v);
                      },
                    ),
                    const Divider(color: Colors.white10),
                    _buildPreferenceSwitch(
                      'New Content Alerts',
                      'Recommendations and updates',
                      _newContentAlerts,
                      (v) {
                        setState(() => _newContentAlerts = v);
                      },
                    ),
                    const Divider(color: Colors.white10),
                    _buildPreferenceSwitch(
                      'Promotional Alerts',
                      'Offers, deals, and coupon codes',
                      _promotionalAlerts,
                      (v) {
                        setState(() => _promotionalAlerts = v);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Notification List Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                'Recent Alerts',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // 3. Notifications Feed
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final alert = _notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: alert.isUnread
                          ? AppColors.primary.withOpacity(0.3)
                          : const Color(0xFF1F1F1F),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon block
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          alert.icon,
                          color: alert.isUnread
                              ? AppColors.primary
                              : Colors.white70,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Text Message details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    alert.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: alert.isUnread
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  alert.timestamp,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              alert.message,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Unread Yellow dot indicator
                      if (alert.isUnread) ...[
                        const SizedBox(width: 10),
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }, childCount: _notifications.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
      ),
      activeColor: AppColors.primary,
      value: value,
      onChanged: onChanged,
    );
  }
}
