import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  final String? profileId;
  const EditProfileScreen({super.key, this.profileId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  late Box<dynamic> _profileBox;
  bool _isBoxReady = false;

  // Form parameters
  int _selectedAvatarIndex = 0;
  bool _isKids = false;

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
    _loadProfileDetails();
  }

  void _loadProfileDetails() {
    if (widget.profileId != null) {
      final profile = Map<String, dynamic>.from(
        _profileBox.get(widget.profileId) as Map,
      );
      _nameController.text = (profile['name'] as String? ?? '');
      _selectedAvatarIndex = profile['avatarIndex'] as int? ?? 0;
      _isKids = profile['isKids'] as bool? ?? false;
    }
    setState(() {
      _isBoxReady = true;
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a profile name.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final id = widget.profileId ?? 'p_${DateTime.now().millisecondsSinceEpoch}';
    final profileData = {
      'id': id,
      'name': name,
      'avatarIndex': _selectedAvatarIndex,
      'isKids': _isKids,
    };

    await _profileBox.put(id, profileData);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.profileId != null
                ? 'Profile updated successfully!'
                : 'Profile created successfully!',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop();
    }
  }

  Future<void> _deleteProfile() async {
    if (widget.profileId == 'p_1') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primary Profile cannot be deleted.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await _profileBox.delete(widget.profileId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile deleted successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

    final isNew = widget.profileId == null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isNew ? 'Create Profile' : 'Edit Profile',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar Color Indicator
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor:
                    _avatarColors[_selectedAvatarIndex % _avatarColors.length],
                child: Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text.substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Avatar Color Picker Label
            const Text(
              'Select Avatar Theme Color',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Horizontal Avatar Theme Colors Selector
            SizedBox(
              height: 56,
              child: Center(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: _avatarColors.length,
                  itemBuilder: (context, index) {
                    final color = _avatarColors[index];
                    final isSelected = index == _selectedAvatarIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatarIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                LucideIcons.check,
                                color: Colors.black,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Profile Name Input field
            const Text(
              'Profile Name',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (val) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Enter profile name'),
            ),
            const SizedBox(height: 24),

            // Kids Mode Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Kids Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Restrict content access to age PG & below',
                style: TextStyle(color: AppColors.muted),
              ),
              activeColor: AppColors.primary,
              value: _isKids,
              onChanged: (val) {
                setState(() {
                  _isKids = val;
                });
              },
            ),
            const SizedBox(height: 40),

            // Save button
            PrimaryButton(
              label: isNew ? 'Create Profile' : 'Save Changes',
              onPressed: _saveProfile,
            ),

            // Delete option (only if editing subprofile)
            if (!isNew && widget.profileId != 'p_1') ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _deleteProfile,
                icon: const Icon(LucideIcons.trash2, size: 18),
                label: const Text(
                  'Delete Profile',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
