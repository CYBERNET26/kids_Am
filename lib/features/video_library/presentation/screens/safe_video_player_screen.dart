import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/features/video_library/domain/models/video_item.dart';

class SafeVideoPlayerScreen extends StatefulWidget {
  final VideoItem video;

  const SafeVideoPlayerScreen({super.key, required this.video});

  @override
  State<SafeVideoPlayerScreen> createState() => _SafeVideoPlayerScreenState();
}

class _SafeVideoPlayerScreenState extends State<SafeVideoPlayerScreen> {
  // Para YouTube
  YoutubePlayerController? _youtubeController;
  
  // Para videos directos MP4/HLS
  VideoPlayerController? _directVideoController;
  bool _isDirectInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    if (widget.video.isYoutube) {
      final ytId = widget.video.youtubeId;
      if (ytId != null && ytId.isNotEmpty) {
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: ytId,
          autoPlay: true,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            mute: false,
          ),
        );
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } else {
      final uri = Uri.parse(widget.video.urlOrAssetPath);
      _directVideoController = VideoPlayerController.networkUrl(uri)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isDirectInitialized = true;
            });
            _directVideoController?.play();
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        });
    }
  }

  @override
  void dispose() {
    _youtubeController?.close();
    _directVideoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.video.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: Center(
        child: _hasError
            ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.orange, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'No se pudo reproducir este video.\nComprueba tu conexión o que el enlace sea válido.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver a la Videoteca'),
                    ),
                  ],
                ),
              )
            : widget.video.isYoutube && _youtubeController != null
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: YoutubePlayer(
                      controller: _youtubeController!,
                    ),
                  )
                : _isDirectInitialized && _directVideoController != null
                    ? AspectRatio(
                        aspectRatio: _directVideoController!.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(_directVideoController!),
                            VideoProgressIndicator(
                              _directVideoController!,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: AppColors.primaryBlue,
                                bufferedColor: Colors.grey,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                            _DirectPlayPauseOverlay(controller: _directVideoController!),
                          ],
                        ),
                      )
                    : const CircularProgressIndicator(color: AppColors.sunnyYellow),
      ),
    );
  }
}

class _DirectPlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _DirectPlayPauseOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, VideoPlayerValue value, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            reverseDuration: const Duration(milliseconds: 200),
            child: value.isPlaying
                ? const SizedBox.shrink()
                : Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 80.0,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
