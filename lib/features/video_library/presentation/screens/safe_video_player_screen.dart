import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/features/video_library/domain/models/video_item.dart';

class SafeVideoPlayerScreen extends StatefulWidget {
  final VideoItem video;

  const SafeVideoPlayerScreen({super.key, required this.video});

  @override
  State<SafeVideoPlayerScreen> createState() => _SafeVideoPlayerScreenState();
}

class _SafeVideoPlayerScreenState extends State<SafeVideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    final uri = Uri.parse(widget.video.urlOrAssetPath);
    _controller = VideoPlayerController.networkUrl(uri)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.video.title),
      ),
      body: Center(
        child: _hasError
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.orange, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'No se pudo reproducir este video.\n(Comprueba tu conexión a internet)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              )
            : _isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(_controller),
                        VideoProgressIndicator(_controller, allowScrubbing: true),
                        _PlayPauseOverlay(controller: _controller),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(color: AppColors.sunnyYellow),
      ),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _PlayPauseOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: controller.value.isPlaying
            ? const SizedBox.shrink()
            : Container(
                color: Colors.black26,
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 80.0,
                  ),
                ),
              ),
      ),
    );
  }
}

