import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_am/core/constants/default_videos.dart';
import 'package:kids_am/features/video_library/domain/models/video_item.dart';

class VideoLibraryNotifier extends Notifier<List<VideoItem>> {
  static const _storageKey = 'saved_safe_videos_v2';

  @override
  List<VideoItem> build() {
    _loadFromStorage();
    return defaultEducationalVideos;
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List decoded = jsonDecode(jsonString);
        final loaded = decoded
            .map((e) => VideoItem.fromMap(Map<String, dynamic>.from(e)))
            .toList();
        if (loaded.isNotEmpty) {
          state = loaded;
          return;
        }
      }
    } catch (_) {}
    state = defaultEducationalVideos;
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
    int rewardStars = 3,
  }) {
    final isYt = url.contains('youtube.com') || url.contains('youtu.be');
    final newItem = VideoItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      urlOrAssetPath: url,
      sourceType: isYt ? VideoSourceType.youtube : VideoSourceType.networkUrl,
      category: category,
      rewardStars: rewardStars,
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
    state = defaultEducationalVideos;
    _saveToStorage(defaultEducationalVideos);
  }

  /// Sincroniza en caliente los videos oficiales desde una actualización OTA,
  /// conservando intactos los videos personalizados que el padre haya agregado.
  void syncWithOTAVideos(List<VideoItem> otaVideos) {
    if (otaVideos.isEmpty) return;
    final customVideos = state.where((v) => v.id.startsWith('custom_')).toList();
    final updated = [...otaVideos, ...customVideos];
    state = updated;
    _saveToStorage(updated);
  }
}

final videoLibraryProvider =
    NotifierProvider<VideoLibraryNotifier, List<VideoItem>>(
  VideoLibraryNotifier.new,
);
