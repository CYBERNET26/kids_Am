import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_am/features/profile/domain/models/child_profile.dart';
import 'package:kids_am/features/games/domain/models/game_level.dart';

class ChildProfileNotifier extends Notifier<ChildProfile> {
  @override
  ChildProfile build() {
    return const ChildProfile(
      id: 'child_1',
      name: 'Leo',
      age: 6,
      totalStars: 5,
      mathLevel: 1,
      puzzleLevel: 1,
      chessLevel: 1,
    );
  }

  void recordWin({required GameType gameType}) {
    final currentConsecutive = state.consecutiveWins + 1;
    final newStars = state.totalStars + 1;

    int newMath = state.mathLevel;
    int newPuzzle = state.puzzleLevel;
    int newChess = state.chessLevel;
    int resetWins = currentConsecutive;

    // Con cada 2 victorias consecutivas o al completar el ejercicio, avanza de nivel
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

    state = state.copyWith(
      totalStars: newStars,
      consecutiveWins: resetWins,
      mathLevel: newMath,
      puzzleLevel: newPuzzle,
      chessLevel: newChess,
    );
  }

  void updateName(String newName) {
    state = state.copyWith(name: newName);
  }

  void updateAge(int newAge) {
    state = state.copyWith(age: newAge);
  }

  void setLevels({int? math, int? puzzle, int? chess}) {
    state = state.copyWith(
      mathLevel: math ?? state.mathLevel,
      puzzleLevel: puzzle ?? state.puzzleLevel,
      chessLevel: chess ?? state.chessLevel,
    );
  }
}

final childProfileProvider =
    NotifierProvider<ChildProfileNotifier, ChildProfile>(
  ChildProfileNotifier.new,
);
