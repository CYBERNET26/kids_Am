class ChildProfile {
  final String id;
  final String name;
  final int age;
  final String avatarAsset;
  final int totalStars;
  final int mathLevel;
  final int puzzleLevel;
  final int chessLevel;
  final int consecutiveWins;

  const ChildProfile({
    required this.id,
    required this.name,
    this.age = 6,
    this.avatarAsset = 'assets/avatars/astronaut.png',
    this.totalStars = 0,
    this.mathLevel = 1,
    this.puzzleLevel = 1,
    this.chessLevel = 1,
    this.consecutiveWins = 0,
  });

  ChildProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? avatarAsset,
    int? totalStars,
    int? mathLevel,
    int? puzzleLevel,
    int? chessLevel,
    int? consecutiveWins,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      totalStars: totalStars ?? this.totalStars,
      mathLevel: mathLevel ?? this.mathLevel,
      puzzleLevel: puzzleLevel ?? this.puzzleLevel,
      chessLevel: chessLevel ?? this.chessLevel,
      consecutiveWins: consecutiveWins ?? this.consecutiveWins,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'avatarAsset': avatarAsset,
      'totalStars': totalStars,
      'mathLevel': mathLevel,
      'puzzleLevel': puzzleLevel,
      'chessLevel': chessLevel,
      'consecutiveWins': consecutiveWins,
    };
  }

  factory ChildProfile.fromMap(Map<String, dynamic> map) {
    return ChildProfile(
      id: map['id'] as String? ?? 'default_child',
      name: map['name'] as String? ?? 'Pequeño Explorador',
      age: map['age'] as int? ?? 6,
      avatarAsset: map['avatarAsset'] as String? ?? 'assets/avatars/astronaut.png',
      totalStars: map['totalStars'] as int? ?? 0,
      mathLevel: map['mathLevel'] as int? ?? 1,
      puzzleLevel: map['puzzleLevel'] as int? ?? 1,
      chessLevel: map['chessLevel'] as int? ?? 1,
      consecutiveWins: map['consecutiveWins'] as int? ?? 0,
    );
  }
}

