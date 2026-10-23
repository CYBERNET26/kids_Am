enum GameType { chess, puzzle, visualMath }

class GameLevel {
  final int levelNumber;
  final GameType gameType;
  final String title;
  final String description;
  final int targetScore;
  final int starReward;
  final Map<String, dynamic> gameConfig;

  const GameLevel({
    required this.levelNumber,
    required this.gameType,
    required this.title,
    required this.description,
    this.targetScore = 3,
    this.starReward = 1,
    this.gameConfig = const {},
  });
}

