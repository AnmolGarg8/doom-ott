import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/colors.dart';
import '../../data/models/content_model.dart';
import '../../data/mock/mock_data.dart';
import '../watchlist/bloc/watchlist_bloc.dart';
import '../watchlist/bloc/watchlist_event.dart';
import '../watchlist/bloc/watchlist_state.dart';

class ShortsReelScreen extends StatefulWidget {
  final String startId;
  final bool isTab;

  const ShortsReelScreen({super.key, this.startId = '', this.isTab = false});

  @override
  State<ShortsReelScreen> createState() => _ShortsReelScreenState();
}

class _ShortsReelScreenState extends State<ShortsReelScreen> {
  late final Player _player;
  late final VideoController _controller;
  late final PageController _pageController;

  final List<ContentModel> _shorts = MockData.allContent
      .where((element) => element.type == 'short')
      .toList();

  int _currentIndex = 0;
  bool _isMuted = true;
  bool _isPlaying = true;
  bool _isBuffering = false;
  bool _isExpanded = false;

  // Local stateful likes for shorts feed
  final Set<String> _likedIds = {};

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _playSub;
  StreamSubscription? _bufSub;

  @override
  void initState() {
    super.initState();
    // Configure fullscreen immersive overlays
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Find starting short item index
    final startIndex = widget.isTab
        ? 0
        : _shorts.indexWhere((element) => element.id == widget.startId);
    _currentIndex = startIndex >= 0 ? startIndex : 0;

    // Create PageController initialized at a mid-range index to allow infinite circular looping in both directions
    final initialPage = 5000 * _shorts.length + _currentIndex;
    _pageController = PageController(initialPage: initialPage);

    // Initialize media player
    _player = Player();
    _controller = VideoController(_player);

    _posSub = _player.stream.position.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _durSub = _player.stream.duration.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _playSub = _player.stream.playing.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });
    _bufSub = _player.stream.buffering.listen((buffering) {
      if (mounted) setState(() => _isBuffering = buffering);
    });

    // Muted by default
    _player.setVolume(0.0);

    // Play initial video
    _playVideo(_currentIndex);
  }

  void _playVideo(int index) {
    if (_shorts.isEmpty) return;
    setState(() {
      _isBuffering = true;
      _isExpanded = false;
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    final shortId = _shorts[index].id;
    final videoUrl = shortId == '2'
        ? 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4'
        : shortId == '3'
        ? 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4'
        : 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
    _player.open(Media(videoUrl));
    _player.play();
  }

  void _onPageChanged(int virtualIndex) {
    final nextIndex = virtualIndex % _shorts.length;
    setState(() {
      _currentIndex = nextIndex;
    });
    _playVideo(nextIndex);
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _player.setVolume(_isMuted ? 0.0 : 100.0);
  }

  @override
  void dispose() {
    // Restore orientation and system chrome overlays on exit
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _posSub?.cancel();
    _durSub?.cancel();
    _playSub?.cancel();
    _bufSub?.cancel();
    _pageController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shorts.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Vertical PageView
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final activeIndex = index % _shorts.length;
              final short = _shorts[activeIndex];

              // Render current active page with player, otherwise just show background/poster image
              final isCurrent = activeIndex == _currentIndex;

              return GestureDetector(
                onTap: _togglePlayPause,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (isCurrent)
                      Video(controller: _controller, fit: BoxFit.cover)
                    else
                      CachedNetworkImage(
                        imageUrl: short.posterUrl,
                        fit: BoxFit.cover,
                      ),

                    // Blur/shimmer loader during buffer changes
                    if (isCurrent && _isBuffering)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                    // Shadows at bottom and top to ensure overlay buttons and texts are readable
                    _buildGradients(),

                    // Information Overlays (Bottom and Right panels)
                    _buildUIOverlay(short),
                  ],
                ),
              );
            },
          ),

          // 2. Playback progress bar at the very top of screen
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Progress Track
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _duration > Duration.zero
                            ? (_position.inMilliseconds /
                                  _duration.inMilliseconds)
                            : 0.0,
                        backgroundColor: Colors.white24,
                        color: AppColors.emberAmber,
                        minHeight: 3.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Floating Top controls (X, Volume/Mute)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Close Button
                        widget.isTab
                            ? const SizedBox(width: 48)
                            : IconButton(
                                icon: const Icon(
                                  LucideIcons.x,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                        // Mute/Volume Icon
                        IconButton(
                          icon: Icon(
                            _isMuted
                                ? LucideIcons.volumeX
                                : LucideIcons.volume2,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: _toggleMute,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Large Play/Pause indicators when paused
          if (!_isPlaying)
            IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.play,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGradients() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 240,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUIOverlay(ContentModel short) {
    return Stack(
      children: [
        // Bottom details
        Positioned(
          bottom: 30,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                short.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Genre tag chip row
              Row(
                children: short.genre.take(2).map((g) {
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      g,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              // Expandable synopsis text
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: RichText(
                  maxLines: _isExpanded ? 6 : 2,
                  overflow: TextOverflow.clip,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: _isExpanded
                            ? short.synopsis
                            : (short.synopsis.length > 80
                                  ? '${short.synopsis.substring(0, 80)}...'
                                  : short.synopsis),
                      ),
                      if (short.synopsis.length > 80)
                        TextSpan(
                          text: _isExpanded ? ' Less' : ' more',
                          style: const TextStyle(
                            color: AppColors.emberAmber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right panel action rail
        Positioned(
          bottom: 30,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Like Button
              _buildActionButton(
                icon: LucideIcons.heart,
                label: 'Like',
                isActive: _likedIds.contains(short.id),
                activeColor: AppColors.emberAmber,
                onTap: () {
                  setState(() {
                    if (_likedIds.contains(short.id)) {
                      _likedIds.remove(short.id);
                    } else {
                      _likedIds.add(short.id);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              // 2. Watchlist Add / Remove Toggle
              BlocBuilder<WatchlistBloc, WatchlistState>(
                builder: (context, state) {
                  final inWatchlist =
                      state is WatchlistLoaded &&
                      state.watchlist.any((element) => element.id == short.id);

                  return _buildActionButton(
                    icon: inWatchlist ? LucideIcons.check : LucideIcons.plus,
                    label: inWatchlist ? 'Added' : 'My List',
                    isActive: inWatchlist,
                    activeColor: AppColors.emberAmber,
                    onTap: () {
                      if (inWatchlist) {
                        context.read<WatchlistBloc>().add(
                          RemoveFromWatchlistRequested(short.id),
                        );
                      } else {
                        context.read<WatchlistBloc>().add(
                          AddToWatchlistRequested(short),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // 3. Share Button
              _buildActionButton(
                icon: LucideIcons.share2,
                label: 'Share',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share link copied to clipboard!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? (activeColor ?? Colors.white) : Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
