enum VideoSourceType { localAsset, networkUrl }

class VideoItem {
  final String id;
  final String title;
  final String description;
  final String urlOrAssetPath;
  final VideoSourceType sourceType;
  final String thumbnailUrl;
  final int durationSeconds;
  final String category;

  const VideoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.urlOrAssetPath,
    this.sourceType = VideoSourceType.networkUrl,
    this.thumbnailUrl = '',
    this.durationSeconds = 0,
    this.category = 'General',
  });

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
    };
  }

  factory VideoItem.fromMap(Map<String, dynamic> map) {
    return VideoItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      urlOrAssetPath: map['urlOrAssetPath'] as String,
      sourceType: VideoSourceType.values.firstWhere(
        (e) => e.name == map['sourceType'],
        orElse: () => VideoSourceType.networkUrl,
      ),
      thumbnailUrl: map['thumbnailUrl'] as String? ?? '',
      durationSeconds: map['durationSeconds'] as int? ?? 0,
      category: map['category'] as String? ?? 'General',
    );
  }
}

