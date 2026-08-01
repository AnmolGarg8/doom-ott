import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/primary_button.dart';

class ParentalControlsScreen extends StatefulWidget {
  final String profileId;
  const ParentalControlsScreen({super.key, required this.profileId});

  @override
  State<ParentalControlsScreen> createState() => _ParentalControlsScreenState();
}

class _ParentalControlsScreenState extends State<ParentalControlsScreen> {
  final TextEditingController _pinController = TextEditingController();
  late Box<dynamic> _profileBox;
  bool _isBoxReady = false;

  // Settings states
  bool _isLockEnabled = false;
  double _ratingLimitIndex = 3.0; // 0: G, 1: PG, 2: PG-13, 3: R / 18+
  final Set<String> _blockedGenres = {};

  final List<String> _ratingTiers = ['G', 'PG', 'PG-13', '18+'];
  final List<String> _genresToBlock = [
    'Horror',
    'Adult Content',
    'Thriller',
    'Romance',
  ];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _profileBox = await Hive.openBox<dynamic>('user_profiles');
    _loadParentalSettings();
  }

  void _loadParentalSettings() {
    final profile = Map<String, dynamic>.from(
      _profileBox.get(widget.profileId) as Map,
    );
    _pinController.text = (profile['parentalPin'] as String? ?? '');
    _isLockEnabled = _pinController.text.isNotEmpty;
    _ratingLimitIndex = (profile['maxRatingIndex'] as double? ?? 3.0);

    final blocked = profile['blockedGenres'] as List<dynamic>? ?? [];
    _blockedGenres.addAll(blocked.cast<String>());

    setState(() {
      _isBoxReady = true;
    });
  }

  Future<void> _saveSettings() async {
    final pin = _pinController.text.trim();
    if (_isLockEnabled && pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set a valid 4-digit PIN.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final profile = Map<String, dynamic>.from(
      _profileBox.get(widget.profileId) as Map,
    );
    profile['parentalPin'] = _isLockEnabled ? pin : '';
    profile['maxRatingIndex'] = _ratingLimitIndex;
    profile['blockedGenres'] = _blockedGenres.toList();

    await _profileBox.put(widget.profileId, profile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parental controls saved successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
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
          'Parental Restrictions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. PIN Lock Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Enable Parental Lock PIN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text(
                'Require a 4-digit PIN to switch profiles or view restricted content',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              activeColor: AppColors.primary,
              value: _isLockEnabled,
              onChanged: (val) {
                setState(() {
                  _isLockEnabled = val;
                  if (!val) _pinController.clear();
                });
              },
            ),
            const SizedBox(height: 16),

            // PIN Code Input Field (if enabled)
            if (_isLockEnabled) ...[
              const Text(
                '4-Digit Lock PIN',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                style: const TextStyle(
                  color: Colors.white,
                  letterSpacing: 8,
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter 4-digit PIN',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),

            // 2. Rating Restriction slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Max Allowed Rating',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    _ratingTiers[_ratingLimitIndex.round()],
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: Colors.white10,
                thumbColor: AppColors.primary,
              ),
              child: Slider(
                value: _ratingLimitIndex,
                min: 0,
                max: 3,
                divisions: 3,
                onChanged: (val) {
                  setState(() {
                    _ratingLimitIndex = val;
                  });
                },
              ),
            ),
            const Text(
              'Show titles rated at or below the selected maturity rating tier.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16),

            // 3. Block genres list
            const Text(
              'Block Specific Genres',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ..._genresToBlock.map((genre) {
              final isBlocked = _blockedGenres.contains(genre);
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  genre,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                activeColor: AppColors.primary,
                checkColor: Colors.black,
                value: isBlocked,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _blockedGenres.add(genre);
                    } else {
                      _blockedGenres.remove(genre);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 40),

            // Save changes button
            PrimaryButton(label: 'Save Constraints', onPressed: _saveSettings),
          ],
        ),
      ),
    );
  }
}
