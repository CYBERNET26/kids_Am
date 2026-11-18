import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_am/features/profile/domain/models/child_profile.dart';
import 'package:kids_am/features/games/domain/models/game_level.dart';

class ChildProfileNotifier extends Notifier<ChildProfile> {
  static const _storageKey = 'saved_child_profile';

  static const _defaultProfile = ChildProfile(
    id: 'child_1',
    name: 'Leo',
    age: 6,
    totalStars: 10,
    mathLevel: 1,
    puzzleLevel: 1,
    chessLevel: 1,
  );

  @override
  ChildProfile build() {
    _loadFromStorage();
    return _defaultProfile;
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final decoded = jsonDecode(jsonString);
        state = ChildProfile.fromMap(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage(ChildProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(profile.toMap());
      await prefs.setString(_storageKey, jsonString);
    } catch (_) {}
  }

  void recordWin({required GameType gameType}) {
    final currentConsecutive = state.consecutiveWins + 1;
    final newStars = state.totalStars + 1;

    int newMath = state.mathLevel;
    int newPuzzle = state.puzzleLevel;
    int newChess = state.chessLevel;
    int resetWins = currentConsecutive;

    if (currentConsecutive >= 2) {
      resetWins = 0;
      switch (gameType) {
        case GameType.visualMath:
          newMath = (newMath < 10) ? newMath + 1 : newMath;
          break;
        case GameType.puzzle:
          newPuzzle = (newPuzzle < 5) ? newPuzzle + 1 : newPuzzle;
          break;
        case GameType.chess:
          newChess = (newChess < 6) ? newChess + 1 : newChess;
          break;
      }
    }

    final updated = state.copyWith(
      totalStars: newStars,
      consecutiveWins: resetWins,
      mathLevel: newMath,
      puzzleLevel: newPuzzle,
      chessLevel: newChess,
    );
    state = updated;
    _saveToStorage(updated);
  }

  void addStars(int count) {
    if (count > 0) {
      final updated = state.copyWith(totalStars: state.totalStars + count);
      state = updated;
      _saveToStorage(updated);
    }
  }

  bool deductStars(int amount) {
    if (state.totalStars >= amount) {
      final updated = state.copyWith(totalStars: state.totalStars - amount);
      state = updated;
      _saveToStorage(updated);
      return true;
    }
    return false;
  }

  void updateName(String newName) {
    final trimmed = newName.trim();
    if (trimmed.isNotEmpty) {
      final updated = state.copyWith(name: trimmed);
      state = updated;
      _saveToStorage(updated);
    }
  }

  void updateAge(int newAge) {
    final updated = state.copyWith(age: newAge);
    state = updated;
    _saveToStorage(updated);
  }

  void setLevels({int? math, int? puzzle, int? chess}) {
    final updated = state.copyWith(
      mathLevel: math ?? state.mathLevel,
      puzzleLevel: puzzle ?? state.puzzleLevel,
      chessLevel: chess ?? state.chessLevel,
    );
    state = updated;
    _saveToStorage(updated);
  }
}

final childProfileProvider =
    NotifierProvider<ChildProfileNotifier, ChildProfile>(
  ChildProfileNotifier.new,
);
