import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../home/bloc/content_bloc.dart';
import '../home/bloc/content_event.dart';

class ProfilePickerScreen extends StatefulWidget {
  final bool manageMode;
  const ProfilePickerScreen({super.key, this.manageMode = false});

  @override
  State<ProfilePickerScreen> createState() => _ProfilePickerScreenState();
}

class _ProfilePickerScreenState extends State<ProfilePickerScreen> {
  late Box<dynamic> _profileBox;
  List<Map<String, dynamic>> _profiles = [];
  String _activeProfileId = '1';
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
    final authRepository = context.read<AuthRepository>();
    _profileBox = await Hive.openBox<dynamic>('user_profiles');

    try {
      await authRepository.getCurrentUser();
    } catch (_) {}

    if (!mounted) return;
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

  Future<void> _selectProfile(Map<String, dynamic> profile) async {
    if (widget.manageMode) {
      // Route to edit screen
      context
          .push('/edit-profile?id=${profile['id']}')
          .then((_) => _loadProfiles());
    } else {
      // Set active profile and go to home
      await _profileBox.put('active_id', profile['id']);
      if (mounted) {
        context.read<ContentBloc>().add(LoadHomeContent());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to profile: ${profile['name']}'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 1),
          ),
        );
        context.go('/home');
      }
    }
  }

  void _addNewProfile() {
    if (_profiles.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum profile limit (4) reached.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    // Route to edit profile screen (without passing id to represent creating a new profile)
    context.push('/edit-profile').then((_) => _loadProfiles());
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBoxReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.manageMode
            ? IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          widget.manageMode ? 'Manage Profiles' : 'Who\'s Watching?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!widget.manageMode)
            TextButton(
              onPressed: () {
                context
                    .push('/profile-picker?manage=true')
                    .then((_) => _loadProfiles());
              },
              child: const Text(
                'Manage',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Grid list of profiles
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.85,
                ),
                itemCount: _profiles.length + (_profiles.length < 4 ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _profiles.length) {
                    // Add Profile Tile
                    return _buildAddProfileTile();
                  }

                  final profile = _profiles[index];
                  final isCurrentActive = profile['id'] == _activeProfileId;
                  final avatarIdx = profile['avatarIndex'] as int? ?? 0;
                  final avatarColor =
                      _avatarColors[avatarIdx % _avatarColors.length];
                  final bool isKids = profile['isKids'] as bool? ?? false;

                  return GestureDetector(
                    onTap: () => _selectProfile(profile),
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Avatar Circle
                              Container(
                                decoration: BoxDecoration(
                                  color: avatarColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isCurrentActive && !widget.manageMode
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    if (isCurrentActive && !widget.manageMode)
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                  ],
                                ),
                                child: Center(
                                  child: widget.manageMode
                                      ? const CircleAvatar(
                                          radius: 40,
                                          backgroundColor: Colors.black45,
                                          child: Icon(
                                            LucideIcons.pencil,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        )
                                      : Text(
                                          profile['name']
                                              .toString()
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 32,
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
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'KIDS',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile['name'] as String,
                          style: TextStyle(
                            color: isCurrentActive
                                ? AppColors.primary
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddProfileTile() {
    return GestureDetector(
      onTap: _addNewProfile,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white24,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Center(
                child: Icon(LucideIcons.plus, color: Colors.white54, size: 36),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Add Profile',
            style: TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
