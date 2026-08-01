import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/constants.dart';
import '../../core/widgets/custom_app_bar.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedChannelIndex = 0;

  final List<Map<String, dynamic>> _channels = [
    {
      'name': 'Doom Action HD',
      'logo': 'A',
      'color': Colors.redAccent,
      'nowPlaying': 'Doom: The Beginning',
      'nextPlaying': 'Velocity (06:00 PM)',
      'viewers': '14.2K',
      'progress': 0.45,
      'image': 'https://picsum.photos/seed/action_live/600/350',
    },
    {
      'name': 'Doom Sci-Fi HD',
      'logo': 'S',
      'color': Colors.blueAccent,
      'nowPlaying': 'Quantum Shift',
      'nextPlaying': 'Chronos Gate (05:30 PM)',
      'viewers': '9.8K',
      'progress': 0.82,
      'image': 'https://picsum.photos/seed/scifi_live/600/350',
    },
    {
      'name': 'Doom Comedy',
      'logo': 'C',
      'color': Colors.amberAccent,
      'nowPlaying': 'Laughter Therapy',
      'nextPlaying': 'Roommates (06:15 PM)',
      'viewers': '5.4K',
      'progress': 0.15,
      'image': 'https://picsum.photos/seed/comedy_live/600/350',
    },
    {
      'name': 'Doom Originals',
      'logo': 'O',
      'color': AppColors.primary,
      'nowPlaying': 'Doom Eclipse',
      'nextPlaying': 'Doom Legacy (07:00 PM)',
      'viewers': '22.1K',
      'progress': 0.60,
      'image': 'https://picsum.photos/seed/originals_live/600/350',
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeChannel = _channels[_selectedChannelIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Live Player Placeholder
                Stack(
                  children: [
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(activeChannel['image'] as String),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: 280,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                            Colors.black87,
                            Colors.black,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.4, 0.8, 1.0],
                        ),
                      ),
                    ),
                    // Centered Play Button overlay
                    Positioned.fill(
                      child: Center(
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.black45,
                          child: IconButton(
                            icon: const Icon(
                              LucideIcons.play,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Playing ${activeChannel['name']} Live...',
                                  ),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    // Live Indicator & Channel Badge
                    Positioned(
                      top: 100,
                      left: 16,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  LucideIcons.radio,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.eye,
                                  size: 12,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  activeChannel['viewers'] as String,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Title overlay at player bottom
                    Positioned(
                      bottom: 12,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeChannel['name'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeChannel['nowPlaying'] as String,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Live Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: activeChannel['progress'] as double,
                        color: AppColors.primary,
                        backgroundColor: Colors.white10,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Now Broadcasting',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Up next: ${activeChannel['nextPlaying']}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Channel List Selection
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Channels',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _channels.length,
                  itemBuilder: (context, index) {
                    final ch = _channels[index];
                    final isSelected = index == _selectedChannelIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedChannelIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF161616)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppThemeConstants.radiusCard,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFF1F1F1F),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Channel Logo Avatar
                            CircleAvatar(
                              backgroundColor: ch['color'] as Color,
                              radius: 20,
                              child: Text(
                                ch['logo'] as String,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ch['name'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Live: ${ch['nowPlaying']}',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Indicator icon
                            if (isSelected)
                              const Icon(
                                LucideIcons.volume2,
                                color: AppColors.primary,
                              )
                            else
                              const Icon(
                                LucideIcons.chevronRight,
                                color: AppColors.muted,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Custom Transparent-to-Solid AppBar
          CustomAppBar(
            scrollController: _scrollController,
            title: const Row(
              children: [
                Icon(LucideIcons.tv, color: AppColors.primary, size: 24),
                SizedBox(width: 8),
                Text('LIVE TV'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
