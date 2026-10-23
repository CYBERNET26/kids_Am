import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_am/features/video_library/domain/models/video_item.dart';

class VideoLibraryNotifier extends Notifier<List<VideoItem>> {
  static final List<VideoItem> _initialSafeVideos = [
    const VideoItem(
      id: 'vid_1',
      title: 'Aprende los Números Cantando 🎵',
      description: 'Canción divertida de números del 1 al 10',
      urlOrAssetPath:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      thumbnailUrl: 'assets/images/video_thumb_math.png',
      category: 'Matemáticas',
    ),
    const VideoItem(
      id: 'vid_2',
      title: 'El Baile de las Figuras Geométricas 📐',
      description: 'Descubre el círculo, cuadrado y triángulo',
      urlOrAssetPath:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      thumbnailUrl: 'assets/images/video_thumb_shapes.png',
      category: 'Geometría',
    ),
    const VideoItem(
      id: 'vid_3',
      title: 'El Secreto de la Torre de Ajedrez 🏰',
      description: 'Aprende cómo avanza la Torre por filas y columnas',
      urlOrAssetPath:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      thumbnailUrl: 'assets/images/video_thumb_chess.png',
      category: 'Ajedrez',
    ),
  ];

  @override
  List<VideoItem> build() {
    return _initialSafeVideos;
  }

  void addVideo({
    required String title,
    required String url,
    required String category,
    String description = '',
  }) {
    final newItem = VideoItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      urlOrAssetPath: url,
      sourceType: VideoSourceType.networkUrl,
      category: category,
    );
    state = [...state, newItem];
  }

  void removeVideo(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final videoLibraryProvider =
    NotifierProvider<VideoLibraryNotifier, List<VideoItem>>(
  VideoLibraryNotifier.new,
);

