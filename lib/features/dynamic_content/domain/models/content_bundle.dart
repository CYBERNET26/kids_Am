import 'package:kids_am/features/stories/domain/models/story_item.dart';
import 'package:kids_am/features/video_library/domain/models/video_item.dart';

class ContentBundle {
  final int bundleVersion;
  final String updatedAt;
  final String releaseNotes;
  final List<StoryItem> stories;
  final List<VideoItem> videos;
  final Map<String, dynamic> mathSettings;
  final Map<String, dynamic> tutorConfig;

  const ContentBundle({
    required this.bundleVersion,
    required this.updatedAt,
    this.releaseNotes = '',
    required this.stories,
    required this.videos,
    this.mathSettings = const {},
    this.tutorConfig = const {},
  });

  Map<String, dynamic> toJson() => {
        'bundleVersion': bundleVersion,
        'updatedAt': updatedAt,
        'releaseNotes': releaseNotes,
        'stories': stories.map((s) => s.toJson()).toList(),
        'videos': videos.map((v) => v.toJson()).toList(),
        'mathSettings': mathSettings,
        'tutorConfig': tutorConfig,
      };

  factory ContentBundle.fromJson(Map<String, dynamic> json) {
    final rawStories = json['stories'] as List? ?? [];
    final rawVideos = json['videos'] as List? ?? [];

    return ContentBundle(
      bundleVersion: json['bundleVersion'] as int? ?? 1,
      updatedAt: json['updatedAt'] as String? ?? '',
      releaseNotes: json['releaseNotes'] as String? ?? '',
      stories: rawStories
          .map((s) => StoryItem.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList(),
      videos: rawVideos
          .map((v) => VideoItem.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList(),
      mathSettings: Map<String, dynamic>.from(json['mathSettings'] as Map? ?? {}),
      tutorConfig: Map<String, dynamic>.from(json['tutorConfig'] as Map? ?? {}),
    );
  }
}
