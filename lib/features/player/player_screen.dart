import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
        if (mounted) setState(() => _position = p);
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
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Switched to ${ep['title']}'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Failed to load episode stream: $e'),
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
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: Colors.white),
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
                  ],
                ),
              ),
      ),
    );
  }
}
