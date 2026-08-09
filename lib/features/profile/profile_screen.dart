import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';
import '../home/bloc/content_bloc.dart';
import '../home/bloc/content_event.dart';
import '../../core/theme/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Box<dynamic> _profileBox;
  List<Map<String, dynamic>> _profiles = [];
  String _activeProfileId = '';
  bool _isBoxReady = false;

  final List<Color> _avatarColors = const [
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _profileBox = await Hive.openBox<dynamic>('user_profiles');
    _loadProfiles();
  }

  void _loadProfiles() {
    final activeId =
        _profileBox.get('active_id') as String? ?? '';
    final keys = _profileBox.keys.where((k) => k != 'active_id').toList();

    final List<Map<String, dynamic>> list = [];
    for (final k in keys) {
      final val = Map<String, dynamic>.from(_profileBox.get(k) as Map);
      list.add(val);
    }

    setState(() {
      _profiles = list;
      _activeProfileId = activeId;
      _isBoxReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Profile'), centerTitle: false),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            final user = state.user;

            // Compute active profile details
            final activeProfile = _profiles.firstWhere(
              (p) => p['id'] == _activeProfileId,
              orElse: () => {},
            );
            final displayName = activeProfile.isNotEmpty
                ? activeProfile['name'] as String
                : user.name;

            return ListView(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 16.0,
                bottom: 120.0,
              ),
              children: [
                // User info header
                Center(
                  child: Column(
                    children: [
                      // Sub-profile row
                      _buildProfilesRow(context),

                      const SizedBox(height: 24),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? user.phone ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subscription status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: user.isSubscribed
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : Colors.white10,
                          border: Border.all(
                            color: user.isSubscribed
                                ? AppColors.primary
                                : Colors.white24,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.isSubscribed
                              ? 'Doom ${user.subscriptionTier}'
                              : 'Free Tier Member',
                          style: TextStyle(
                            color: user.isSubscribed
                                ? AppColors.primary
                                : AppColors.onBackground,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Settings lists
                _buildSectionTitle('Account'),
                _buildListTile(
                  icon: LucideIcons.creditCard,
                  title: 'Manage Subscription',
                  subtitle: user.isSubscribed
                      ? 'Change plans or billing info'
                      : 'Unlock Doom VIP and HDR quality',
                  onTap: () => context.push('/subscription'),
                ),
                const Divider(),
                _buildListTile(
                  icon: LucideIcons.history,
                  title: 'Payment History',
                  subtitle: 'Past invoices and transactions',
                  onTap: () => context.push('/payment-history'),
                ),
                const Divider(),
                _buildListTile(
                  icon: LucideIcons.monitor,
                  title: 'Manage Devices',
                  subtitle: 'Manage active device sessions',
                  onTap: () => context.push('/manage-devices'),
                ),
                const Divider(),
                _buildListTile(
                  icon: LucideIcons.shieldCheck,
                  title: 'Parental Controls',
                  subtitle: 'Manage content restrictions per profile',
                  onTap: () =>
                      context.push('/parental-controls?id=$_activeProfileId'),
                ),
                const Divider(),
                _buildListTile(
                  icon: LucideIcons.settings,
                  title: 'Settings',
                  subtitle: 'App preferences and local storage',
                  onTap: () => context.push('/settings'),
                ),
                const Divider(),
                _buildListTile(
                  icon: LucideIcons.shieldAlert,
                  title: 'Legal & Help',
                  subtitle: 'Terms of service, privacy policy, FAQs',
                  onTap: () => context.push('/legal'),
                ),

                const SizedBox(height: 40),
                // Sign out button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                  },
                  icon: const Icon(LucideIcons.logOut, size: 18),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Unauthenticated'));
        },
      ),
    );
  }

  Widget _buildProfilesRow(BuildContext context) {
    if (!_isBoxReady) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 105,
          child: Center(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _profiles.length + (_profiles.length < 4 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _profiles.length) {
                  // Add Profile Tile
                  return _buildAddProfileTile(context);
                }

                final profile = _profiles[index];
                final isCurrentActive = profile['id'] == _activeProfileId;
                final avatarIdx = profile['avatarIndex'] as int? ?? 0;
                final avatarColor =
                    _avatarColors[avatarIdx % _avatarColors.length];
                final bool isKids = profile['isKids'] as bool? ?? false;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: GestureDetector(
                    onTap: () async {
                      await _profileBox.put('active_id', profile['id']);
                      setState(() {
                        _activeProfileId = profile['id'];
                      });
                      if (context.mounted) {
                        context.read<ContentBloc>().add(LoadHomeContent());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Switched to profile: ${profile['name']}',
                            ),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    onLongPress: () {
                      context
                          .push('/edit-profile?id=${profile['id']}')
                          .then((_) => _loadProfiles());
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Avatar Circle
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: avatarColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCurrentActive
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  if (isCurrentActive)
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  profile['name']
                                      .toString()
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            // Kids badge overlay
                            if (isKids)
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'KIDS',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          profile['name'] as String,
                          style: TextStyle(
                            color: isCurrentActive
                                ? AppColors.primary
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Manage Profiles text link
        TextButton.icon(
          onPressed: () {
            context.push('/profile-picker').then((_) => _loadProfiles());
          },
          icon: const Icon(
            LucideIcons.users,
            size: 14,
            color: AppColors.primary,
          ),
          label: const Text(
            'Manage Profiles',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddProfileTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GestureDetector(
        onTap: () {
          context.push('/edit-profile').then((_) => _loadProfiles());
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.plus,
                color: AppColors.muted,
                size: 28,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add Profile',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  Widget _buildListTile({
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
        child: Icon(icon, color: AppColors.onBackground, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
      ),
      trailing: const Icon(
        LucideIcons.chevronRight,
        color: AppColors.muted,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
