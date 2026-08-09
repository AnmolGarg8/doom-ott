import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../content_detail/bloc/content_detail_bloc.dart';
import '../content_detail/bloc/content_detail_state.dart';
import '../content_detail/bloc/content_detail_event.dart';
import '../../data/models/content_model.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/watchlist_repository.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/empty_state.dart';

class PlayerScreen extends StatefulWidget {
  final String contentId;

  const PlayerScreen({super.key, required this.contentId});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  bool _isPlayerInitialized = false;
  bool _isLoading = true;
  String? _playbackError;
  ContentModel? _content;

  // Custom Controls States
  bool _showControls = true;
  Timer? _hideTimer;
  Timer? _progressTimer;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isBuffering = false;

  // Auto-play Next Episode States
  int _currentEpisodeIndex = 0;
  bool _isAutoPlayCancelled = false;
  Timer? _autoPlayCountdownTimer;
  int _autoPlaySecondsLeft = 8;
  bool _showAutoPlayOverlay = false;

  // Stream Subscriptions
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _playSub;
  StreamSubscription? _bufStateSub;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);

    final contentState = context.read<ContentDetailBloc>().state;
    if (contentState is ContentDetailLoaded &&
        contentState.content.id == widget.contentId) {
      _content = contentState.content;
      _initializePlayer();
    } else {
      context.read<ContentDetailBloc>().add(
        LoadContentDetail(widget.contentId),
      );
    }
  }

  Future<void> _initializePlayer() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _playbackError = null;
    });

    try {
      final contentRepo = RepositoryProvider.of<ContentRepository>(context);

      _content ??= await contentRepo.getContentById(widget.contentId);

      // Fetch real playback URL from backend: GET /content/{id}/playback-url
      final fetchedUrl = await contentRepo.getPlaybackUrl(widget.contentId);
      if (fetchedUrl.isEmpty) {
        throw Exception('Playback URL is empty or unavailable.');
      }

      if (!mounted) return;

      // Configure Screen Orientation / Immersion based on type
      if (_content?.type != 'short') {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }

      _player.open(Media(fetchedUrl));

      // Listen to Player Streams
      _posSub = _player.stream.position.listen((p) {
        if (mounted) {
          setState(() => _position = p);
          _checkAutoPlayProgress(p);
        }
      });
      _durSub = _player.stream.duration.listen((d) {
        if (mounted) setState(() => _duration = d);
      });
      _playSub = _player.stream.playing.listen((playing) {
        if (mounted) setState(() => _isPlaying = playing);
      });
      _bufStateSub = _player.stream.buffering.listen((buffering) {
        if (mounted) setState(() => _isBuffering = buffering);
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlayerInitialized = true;
        });
      }

      _startHideTimer();
      _startProgressTracker();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlayerInitialized = false;
          _playbackError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _startProgressTracker() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (mounted &&
          _isPlayerInitialized &&
          _isPlaying &&
          _duration > Duration.zero) {
        final double progress = _position.inSeconds / _duration.inSeconds;
        if (progress > 0.01 && progress < 0.95 && _content != null) {
          final updatedContent = _content!.copyWith(progress: progress);
          await RepositoryProvider.of<WatchlistRepository>(
            context,
          ).addToContinueWatching(updatedContent);
        }
      }
    });
  }

  Future<bool> _isKidsMode() async {
    try {
      final profileBox = await Hive.openBox<dynamic>('user_profiles');
      final activeProfileId = profileBox.get('active_id') as String?;
      if (activeProfileId != null) {
        final profile = profileBox.get(activeProfileId) as Map?;
        if (profile != null) {
          return profile['isKids'] as bool? ?? false;
        }
      }
    } catch (_) {}
    return false;
  }

  void _checkAutoPlayProgress(Duration p) {
    if (_content?.type != 'series' ||
        _isAutoPlayCancelled ||
        _showAutoPlayOverlay ||
        _duration == Duration.zero) {
      return;
    }

    final episodes = _getMockEpisodes(_content!.id);
    if (_currentEpisodeIndex + 1 >= episodes.length) {
      return; // No next episode
    }

    final timeRemaining = _duration - p;
    if (timeRemaining <= const Duration(seconds: 15) &&
        timeRemaining > Duration.zero) {
      _startAutoPlayCountdown();
    }
  }

  void _startAutoPlayCountdown() {
    setState(() {
      _showAutoPlayOverlay = true;
      _autoPlaySecondsLeft = 8;
    });

    _autoPlayCountdownTimer?.cancel();
    _autoPlayCountdownTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_autoPlaySecondsLeft > 1) {
        setState(() {
          _autoPlaySecondsLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          _showAutoPlayOverlay = false;
        });
        await _playNextEpisode();
      }
    });
  }

  Future<void> _playNextEpisode() async {
    if (_content == null) return;
    final episodes = _getMockEpisodes(_content!.id);
    final nextIndex = _currentEpisodeIndex + 1;
    if (nextIndex >= episodes.length) return;

    setState(() {
      _isLoading = true;
      _showAutoPlayOverlay = false;
    });

    try {
      final contentRepo = RepositoryProvider.of<ContentRepository>(context);

      // Kids Mode defense check
      final isKids = await _isKidsMode();
      if (isKids) {
        final details = await contentRepo.getContentById(_content!.id);
        if (details == null) {
          throw Exception("This title isn't available in Kids Mode");
        }
      }

      final epUrl = await contentRepo.getPlaybackUrl(_content!.id);
      _player.open(Media(epUrl));

      setState(() {
        _currentEpisodeIndex = nextIndex;
        _isAutoPlayCancelled = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${episodes[nextIndex]['title']}'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _playbackError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _skipForward() {
    final target = _position + const Duration(seconds: 10);
    _player.seek(target < _duration ? target : _duration);
    _startHideTimer();
  }

  void _skipBackward() {
    final target = _position - const Duration(seconds: 10);
    _player.seek(target > Duration.zero ? target : Duration.zero);
    _startHideTimer();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  List<Map<String, dynamic>> _getMockEpisodes(String contentId) {
    return List.generate(5, (index) {
      final epNum = index + 1;
      return {
        'title': 'Episode $epNum: Breach Frontiers',
        'duration': '45m',
        'thumbnail': 'https://picsum.photos/seed/${contentId}_ep$epNum/120/70',
        'description':
            'The battle reaches new heights as forces deploy along the borders.',
      };
    });
  }

  void _showEpisodesBottomSheet() {
    if (_content == null) return;
    final episodes = _getMockEpisodes(_content!.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select Episode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: episodes.length,
                  itemBuilder: (context, index) {
                    final ep = episodes[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          ep['thumbnail'] as String,
                          width: 80,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        ep['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        ep['duration'] as String,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () async {
                        final contentRepo =
                            RepositoryProvider.of<ContentRepository>(context);
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(bottomSheetContext);
                        try {
                          final epUrl = await contentRepo.getPlaybackUrl(
                            widget.contentId,
                          );
                          _player.open(Media(epUrl));
                          setState(() {
                            _currentEpisodeIndex = index;
                            _isAutoPlayCancelled = false;
                            _showAutoPlayOverlay = false;
                          });
                          _autoPlayCountdownTimer?.cancel();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Switched to ${ep['title']}'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to load episode stream: $e',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _posSub?.cancel();
    _durSub?.cancel();
    _playSub?.cancel();
    _bufStateSub?.cancel();
    _hideTimer?.cancel();
    _progressTimer?.cancel();
    _autoPlayCountdownTimer?.cancel();

    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isShort = _content?.type == 'short';

    return BlocListener<ContentDetailBloc, ContentDetailState>(
      listener: (context, state) {
        if (state is ContentDetailLoaded && _content == null) {
          setState(() {
            _content = state.content;
          });
          _initializePlayer();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _playbackError != null
            ? Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                body: EmptyState(
                  icon: LucideIcons.alertCircle,
                  title: 'Playback Unavailable',
                  description: _playbackError!,
                  actionLabel: 'Retry',
                  onActionPressed: _initializePlayer,
                ),
              )
            : _isLoading || _content == null || !_isPlayerInitialized
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : GestureDetector(
                onTap: _toggleControls,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Video Viewport
                    Center(
                      child: AspectRatio(
                        aspectRatio: isShort ? 9 / 16 : 16 / 9,
                        child: Video(
                          controller: _controller,
                          controls: NoVideoControls,
                          fit: isShort ? BoxFit.cover : BoxFit.contain,
                        ),
                      ),
                    ),

                    // Loading / Buffering Spinner
                    if (_isBuffering)
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 4,
                        ),
                      ),

                    // Controls Layer Overlay
                    if (_showControls) ...[
                      Container(color: Colors.black38),

                      // TOP BAR: Title, Settings & Back Button
                      Positioned(
                        top: isShort ? 50 : 30,
                        left: 16,
                        right: 16,
                        child: SafeArea(
                          bottom: false,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  LucideIcons.arrowLeft,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _content?.title ?? 'Playing Video',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  LucideIcons.settings,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Settings / Quality adjustment coming soon',
                                      ),
                                      duration: Duration(milliseconds: 1500),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // CENTER BAR: Seek Back, Play/Pause, Seek Forward Controls
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                LucideIcons.rewind,
                                color: Colors.white,
                                size: 36,
                              ),
                              onPressed: _skipBackward,
                            ),
                            const SizedBox(width: 32),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.primary,
                              child: IconButton(
                                icon: Icon(
                                  _isPlaying
                                      ? LucideIcons.pause
                                      : LucideIcons.play,
                                  color: Colors.black,
                                  size: 28,
                                ),
                                onPressed: () {
                                  if (_isPlaying) {
                                    _player.pause();
                                  } else {
                                    _player.play();
                                  }
                                  _startHideTimer();
                                },
                              ),
                            ),
                            const SizedBox(width: 32),
                            IconButton(
                              icon: const Icon(
                                LucideIcons.fastForward,
                                color: Colors.white,
                                size: 36,
                              ),
                              onPressed: _skipForward,
                            ),
                          ],
                        ),
                      ),

                      // BOTTOM BAR: Scrub timeline, scrubber bar, Episodes selector, Fullscreen toggle
                      Positioned(
                        bottom: isShort ? 40 : 20,
                        left: 16,
                        right: 16,
                        child: SafeArea(
                          top: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _formatDuration(_position),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 4,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 6,
                                        ),
                                        activeTrackColor: AppColors.primary,
                                        inactiveTrackColor: AppColors.secondary,
                                        thumbColor: AppColors.primary,
                                        overlayColor: AppColors.primary
                                            .withValues(alpha: 0.2),
                                      ),
                                      child: Slider(
                                        value: _position.inMilliseconds
                                            .toDouble(),
                                        min: 0.0,
                                        max:
                                            _duration.inMilliseconds
                                                    .toDouble() >
                                                0
                                            ? _duration.inMilliseconds
                                                  .toDouble()
                                            : 1.0,
                                        onChanged: (val) {
                                          _player.seek(
                                            Duration(milliseconds: val.toInt()),
                                          );
                                        },
                                        onChangeEnd: (val) {
                                          _startHideTimer();
                                        },
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(_duration),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (_content?.type == 'series')
                                    TextButton.icon(
                                      icon: const Icon(
                                        LucideIcons.listVideo,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Episodes',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: _showEpisodesBottomSheet,
                                    )
                                  else
                                    const SizedBox(),

                                  IconButton(
                                    icon: const Icon(
                                      LucideIcons.screenShare,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      if (MediaQuery.of(context).orientation ==
                                          Orientation.portrait) {
                                        SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.landscapeLeft,
                                          DeviceOrientation.landscapeRight,
                                        ]);
                                      } else {
                                        SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.portraitUp,
                                        ]);
                                      }
                                      _startHideTimer();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (_showAutoPlayOverlay && _content != null)
                      Positioned(
                        bottom: isShort ? 120 : 100,
                        right: 24,
                        child: Container(
                          width: 320,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      _getMockEpisodes(
                                        _content!.id,
                                      )[_currentEpisodeIndex + 1]['thumbnail']
                                          as String,
                                      width: 90,
                                      height: 55,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'NEXT EPISODE',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _getMockEpisodes(
                                            _content!.id,
                                          )[_currentEpisodeIndex + 1]['title']
                                              as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Playing in ${_autoPlaySecondsLeft}s',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showAutoPlayOverlay = false;
                                        _isAutoPlayCancelled = true;
                                      });
                                      _autoPlayCountdownTimer?.cancel();
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    onPressed: () async {
                                      _autoPlayCountdownTimer?.cancel();
                                      await _playNextEpisode();
                                    },
                                    child: const Text(
                                      'Play Now',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
