import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_am/features/stories/data/default_stories.dart';
import 'package:kids_am/features/stories/domain/models/story_item.dart';
import 'package:kids_am/features/dynamic_content/data/services/dynamic_content_service.dart';

class StoriesState {
  final List<StoryItem> stories;
  final int starsPerCorrectQuestion;
  final Set<String> completedStoryIds;

  const StoriesState({
    required this.stories,
    this.starsPerCorrectQuestion = 1,
    this.completedStoryIds = const {},
  });

  StoriesState copyWith({
    List<StoryItem>? stories,
    int? starsPerCorrectQuestion,
    Set<String>? completedStoryIds,
  }) {
    return StoriesState(
      stories: stories ?? this.stories,
      starsPerCorrectQuestion: starsPerCorrectQuestion ?? this.starsPerCorrectQuestion,
      completedStoryIds: completedStoryIds ?? this.completedStoryIds,
    );
  }
}

class StoriesNotifier extends Notifier<StoriesState> {
  static const _starsKey = 'story_stars_per_question';
  static const _completedKey = 'story_completed_ids';

  @override
  StoriesState build() {
    _loadFromPreferences();
    return const StoriesState(stories: defaultStories);
  }

  Future<void> _loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStars = prefs.getInt(_starsKey) ?? 1;
    final savedCompleted = prefs.getStringList(_completedKey) ?? [];

    try {
      final activeBundle = await DynamicContentService.loadActiveBundle();
      final activeStories =
          activeBundle.stories.isNotEmpty ? activeBundle.stories : defaultStories;

      state = state.copyWith(
        stories: activeStories,
        starsPerCorrectQuestion: savedStars,
        completedStoryIds: savedCompleted.toSet(),
      );
    } catch (_) {
      state = state.copyWith(
        starsPerCorrectQuestion: savedStars,
        completedStoryIds: savedCompleted.toSet(),
      );
    }
  }

  /// Actualiza en caliente la lista de cuentos desde una sincronización OTA
  void updateStoriesList(List<StoryItem> newStories) {
    if (newStories.isNotEmpty) {
      state = state.copyWith(stories: newStories);
    }
  }

  Future<void> setStarsPerCorrectQuestion(int stars) async {
    final sanitized = stars.clamp(1, 20);
    state = state.copyWith(starsPerCorrectQuestion: sanitized);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_starsKey, sanitized);
  }

  Future<void> markStoryCompleted(String storyId) async {
    final updated = Set<String>.from(state.completedStoryIds)..add(storyId);
    state = state.copyWith(completedStoryIds: updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedKey, updated.toList());
  }
}

final storiesProvider = NotifierProvider<StoriesNotifier, StoriesState>(
  StoriesNotifier.new,
);
