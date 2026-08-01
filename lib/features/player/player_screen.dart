import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../home/bloc/content_bloc.dart';
import '../home/bloc/content_state.dart';
import '../home/bloc/content_event.dart';
import '../../data/models/content_model.dart';
import '../../core/theme/colors.dart';

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
  ContentModel? _content;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);

    // Load content details to get video URL
    final contentState = context.read<ContentBloc>().state;
    if (contentState is ContentDetailLoaded &&
        contentState.content.id == widget.contentId) {
      _content = contentState.content;
      _initializePlayer();
    } else {
      // Fallback: look up in all content via bloc/repo
      context.read<ContentBloc>().add(LoadContentDetail(widget.contentId));
    }
  }

  void _initializePlayer() {
    if (_content != null) {
      final videoUrl = _content!.id == '2'
          ? 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4'
          : _content!.id == '3'
          ? 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4'
          : 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

      _player.open(Media(videoUrl));
      setState(() {
        _isPlayerInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContentBloc, ContentState>(
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
        body: _content == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  // Video Player
                  if (_isPlayerInitialized)
                    Center(
                      child: Video(
                        controller: _controller,
                        controls: MaterialVideoControls,
                      ),
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),

                  // Top controls overlay (Back button + Title)
                  Positioned(
                    top: 50,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            LucideIcons.arrowLeft,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _content?.title ?? 'Playing Video',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
