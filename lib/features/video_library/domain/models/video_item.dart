enum VideoSourceType { localAsset, networkUrl, youtube }

class VideoItem {
  final String id;
  final String title;
  final String description;
  final String urlOrAssetPath;
  final VideoSourceType sourceType;
  final String thumbnailUrl;
  final int durationSeconds;
  final String category;
  final int rewardStars; // Estrellas que otorga al completarse (configurable)

  const VideoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.urlOrAssetPath,
    this.sourceType = VideoSourceType.networkUrl,
    this.thumbnailUrl = '',
    this.durationSeconds = 0,
    this.category = 'General',
    this.rewardStars = 3,
  });

  static String? extractYoutubeId(String url) {
    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.|m\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|shorts\/|live\/))([\w-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    final uri = Uri.tryParse(url);
    if (uri != null && uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }
    return null;
  }

  bool get isYoutube =>
      sourceType == VideoSourceType.youtube ||
      urlOrAssetPath.contains('youtube.com') ||
      urlOrAssetPath.contains('youtu.be') ||
      extractYoutubeId(urlOrAssetPath) != null;

  String? get youtubeId {
    if (!isYoutube) return null;
    return extractYoutubeId(urlOrAssetPath);
  }

  String get effectiveThumbnail {
    if (thumbnailUrl.isNotEmpty) return thumbnailUrl;
    final ytId = youtubeId;
    if (ytId != null && ytId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$ytId/hqdefault.jpg';
    }
    return '';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'urlOrAssetPath': urlOrAssetPath,
      'sourceType': sourceType.name,
      'thumbnailUrl': thumbnailUrl,
      'durationSeconds': durationSeconds,
      'category': category,
      'rewardStars': rewardStars,
    };
  }

  factory VideoItem.fromMap(Map<String, dynamic> map) {
    final rawUrl = map['urlOrAssetPath'] as String;
    final isYt = rawUrl.contains('youtube.com') || rawUrl.contains('youtu.be');
    final detectedSource = isYt
        ? VideoSourceType.youtube
        : VideoSourceType.values.firstWhere(
            (e) => e.name == map['sourceType'],
            orElse: () => VideoSourceType.networkUrl,
          );

    return VideoItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      urlOrAssetPath: rawUrl,
      sourceType: detectedSource,
      thumbnailUrl: map['thumbnailUrl'] as String? ?? '',
      durationSeconds: map['durationSeconds'] as int? ?? 0,
      category: map['category'] as String? ?? 'General',
      rewardStars: map['rewardStars'] as int? ?? 3,
    );
  }
}
