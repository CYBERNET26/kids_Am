import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/core/services/teacher_voice_service.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/video_library/domain/models/video_item.dart';

class SafeVideoPlayerScreen extends ConsumerStatefulWidget {
  final VideoItem video;

  const SafeVideoPlayerScreen({super.key, required this.video});

  @override
  ConsumerState<SafeVideoPlayerScreen> createState() => _SafeVideoPlayerScreenState();
}

class _SafeVideoPlayerScreenState extends ConsumerState<SafeVideoPlayerScreen> {
  YoutubePlayerController? _youtubeController;
  StreamSubscription? _ytSubscription;

  VideoPlayerController? _directVideoController;
  bool _isDirectInitialized = false;
  bool _hasError = false;

  late ConfettiController _confettiController;
  bool _rewardClaimed = false;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // Permitir orientaciones horizontal y vertical mientras esté en esta pantalla
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

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

        // Escuchar el botón de pantalla completa nativo del reproductor de YouTube
        _youtubeController!.setFullScreenListener((isFs) {
          if (_isFullscreen != isFs) {
            _toggleFullscreen(isFs);
          }
        });

        // Escuchar finalización de video de YouTube
        _ytSubscription = _youtubeController!.stream.listen((value) {
          if (value.playerState == PlayerState.ended && !_rewardClaimed) {
            _onVideoEnded();
          }
        });
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

            // Escuchar finalización en video directo
            _directVideoController?.addListener(() {
              final pos = _directVideoController?.value.position ?? Duration.zero;
              final dur = _directVideoController?.value.duration ?? Duration.zero;
              if (dur > Duration.zero && pos >= dur && !_rewardClaimed) {
                _onVideoEnded();
              }
            });
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

  Future<void> _toggleFullscreen([bool? force]) async {
    final target = force ?? !_isFullscreen;
    if (_isFullscreen == target) return;

    setState(() {
      _isFullscreen = target;
    });

    if (_isFullscreen) {
      // Bloquear en orientación horizontal y ocultar barras del sistema para inmersión
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      // Volver a vertical y restaurar interfaz del sistema
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _onVideoEnded() {
    if (_rewardClaimed) return;
    _rewardClaimed = true;

    // Si estaba en pantalla completa, salir para mostrar cómodamente la celebración
    if (_isFullscreen) {
      _toggleFullscreen(false);
    }

    final profile = ref.read(childProfileProvider);
    final earnedStars = widget.video.rewardStars;
    ref.read(childProfileProvider.notifier).addStars(earnedStars);

    _confettiController.play();
    final speech =
        '¡Felicitaciones ${profile.name}! Viste todo el video educativo y ganaste $earnedStars estrellas brillantes.';
    TeacherVoiceService.instance.speak(speech);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('⭐ ¡Misión Cumplida! ⭐', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text(
              '¡Felicitaciones, ${profile.name}!\nCompletaste el video educativo.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.sunnyYellow.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.orange, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '+$earnedStars Estrellas Ganadas',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // Volver al catálogo
              },
              child: const Text('¡Genial, gracias!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Restaurar siempre la orientación vertical y las barras del sistema al salir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _ytSubscription?.cancel();
    _youtubeController?.close();
    _directVideoController?.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isFullscreen) {
          _toggleFullscreen(false);
        }
      },
      child: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;
          final effectiveFullscreen = _isFullscreen || isLandscape;

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: effectiveFullscreen
                ? null
                : AppBar(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.video.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 17),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.orange, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '+${widget.video.rewardStars}',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 28),
                        tooltip: 'Pantalla Completa Horizontal',
                        onPressed: () => _toggleFullscreen(true),
                      ),
                    ],
                  ),
            body: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: _hasError
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.orange, size: 64),
                              const SizedBox(height: 16),
                              const Text(
                                'No se pudo reproducir este video.\nComprueba tu conexión a internet.',
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
                          ? SizedBox.expand(
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: YoutubePlayer(
                                    controller: _youtubeController!,
                                  ),
                                ),
                              ),
                            )
                          : _isDirectInitialized && _directVideoController != null
                              ? SizedBox.expand(
                                  child: Center(
                                    child: AspectRatio(
                                      aspectRatio: _directVideoController!.value.aspectRatio > 0
                                          ? _directVideoController!.value.aspectRatio
                                          : 16 / 9,
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
                                          _DirectPlayPauseOverlay(
                                            controller: _directVideoController!,
                                            isFullscreen: effectiveFullscreen,
                                            onToggleFullscreen: () =>
                                                _toggleFullscreen(!effectiveFullscreen),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : const CircularProgressIndicator(color: AppColors.sunnyYellow),
                ),
                // Botón flotante para salir de pantalla completa
                if (effectiveFullscreen)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(
                      child: Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _toggleFullscreen(false),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.fullscreen_exit_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DirectPlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  const _DirectPlayPauseOverlay({
    required this.controller,
    required this.isFullscreen,
    required this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
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
                    ? const SizedBox.expand()
                    : Container(
                        color: Colors.black26,
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 80.0,
                          ),
                        ),
                      ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: Material(
            color: Colors.black45,
            shape: const CircleBorder(),
            child: IconButton(
              icon: Icon(
                isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                color: Colors.white,
                size: 26,
              ),
              tooltip: isFullscreen ? 'Salir de pantalla completa' : 'Pantalla completa horizontal',
              onPressed: onToggleFullscreen,
            ),
          ),
        ),
      ],
    );
  }
}
