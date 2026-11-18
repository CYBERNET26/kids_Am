import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_am/features/video_library/domain/models/video_item.dart';

class VideoLibraryNotifier extends Notifier<List<VideoItem>> {
  static const _storageKey = 'saved_safe_videos';

  static final List<VideoItem> _defaultVideos = [
    const VideoItem(
      id: 'vid_yt_1',
      title: 'Aprende los Números del 1 al 10 🎵',
      description: 'Canción didáctica y alegre para contar con animalitos',
      urlOrAssetPath: 'https://www.youtube.com/watch?v=pSqkWk_Q_i4',
      sourceType: VideoSourceType.youtube,
      category: 'Matemáticas',
    ),
    const VideoItem(
      id: 'vid_yt_2',
      title: 'Las Figuras Geométricas Divertidas 🔺🔵',
      description: 'Círculo, cuadrado, triángulo y rectángulo para niños',
      urlOrAssetPath: 'https://www.youtube.com/watch?v=65wZuz-8u-k',
      sourceType: VideoSourceType.youtube,
      category: 'Geometría',
    ),
    const VideoItem(
      id: 'vid_yt_3',
      title: 'Ajedrez para Niños: ¿Cómo se mueve la Torre y el Caballo? 🏰',
      description: 'Cuento interactivo para aprender las piezas de ajedrez',
      urlOrAssetPath: 'https://www.youtube.com/watch?v=kYJv8Z1kZ50',
      sourceType: VideoSourceType.youtube,
      category: 'Ajedrez',
    ),
    const VideoItem(
      id: 'vid_direct_1',
      title: 'La Abejita Laboriosa 🐝',
      description: 'Video corto educativo de la naturaleza',
      urlOrAssetPath: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      sourceType: VideoSourceType.networkUrl,
      category: 'Ciencias',
    ),
  ];

  @override
  List<VideoItem> build() {
    _loadFromStorage();
    return _defaultVideos;
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List decoded = jsonDecode(jsonString);
        final loaded = decoded.map((e) => VideoItem.fromMap(Map<String, dynamic>.from(e))).toList();
        if (loaded.isNotEmpty) {
          state = loaded;
        }
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage(List<VideoItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(items.map((e) => e.toMap()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (_) {}
  }

  void addVideo({
    required String title,
    required String url,
    required String category,
    String description = '',
  }) {
    final isYt = url.contains('youtube.com') || url.contains('youtu.be');
    final newItem = VideoItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      urlOrAssetPath: url,
      sourceType: isYt ? VideoSourceType.youtube : VideoSourceType.networkUrl,
      category: category,
    );
    final updated = [...state, newItem];
    state = updated;
    _saveToStorage(updated);
  }

  void removeVideo(String id) {
    final updated = state.where((item) => item.id != id).toList();
    state = updated;
    _saveToStorage(updated);
  }

  void restoreDefaults() {
    state = _defaultVideos;
    _saveToStorage(_defaultVideos);
  }
}

final videoLibraryProvider =
    NotifierProvider<VideoLibraryNotifier, List<VideoItem>>(
  VideoLibraryNotifier.new,
);
