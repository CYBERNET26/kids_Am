import 'dart:convert';

enum MathOperation {
  addition('+', 'Suma'),
  subtraction('−', 'Resta'),
  multiplication('×', 'Multiplicación'),
  division('÷', 'División');

  final String symbol;
  final String label;
  const MathOperation(this.symbol, this.label);

  static MathOperation fromSymbol(String symbol) {
    switch (symbol) {
      case '+':
        return MathOperation.addition;
      case '−':
      case '-':
        return MathOperation.subtraction;
      case '×':
      case '*':
      case 'x':
        return MathOperation.multiplication;
      case '÷':
      case '/':
        return MathOperation.division;
      default:
        return MathOperation.addition;
    }
  }
}

class CustomExercise {
  final String id;
  final MathOperation operation;
  final int firstNum;
  final int secondNum;
  final int correctResult;
  final String note;
  final DateTime createdAt;
  final bool isCompleted;

  const CustomExercise({
    required this.id,
    required this.operation,
    required this.firstNum,
    required this.secondNum,
    required this.correctResult,
    this.note = '',
    required this.createdAt,
    this.isCompleted = false,
  });

  CustomExercise copyWith({
    String? id,
    MathOperation? operation,
    int? firstNum,
    int? secondNum,
    int? correctResult,
    String? note,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return CustomExercise(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      firstNum: firstNum ?? this.firstNum,
      secondNum: secondNum ?? this.secondNum,
      correctResult: correctResult ?? this.correctResult,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operation': operation.symbol,
      'firstNum': firstNum,
      'secondNum': secondNum,
      'correctResult': correctResult,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory CustomExercise.fromMap(Map<String, dynamic> map) {
    return CustomExercise(
      id: map['id'] as String,
      operation: MathOperation.fromSymbol(map['operation'] as String? ?? '+'),
      firstNum: (map['firstNum'] as num?)?.toInt() ?? 1,
      secondNum: (map['secondNum'] as num?)?.toInt() ?? 1,
      correctResult: (map['correctResult'] as num?)?.toInt() ?? 2,
      note: map['note'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomExercise.fromJson(String source) =>
      CustomExercise.fromMap(json.decode(source) as Map<String, dynamic>);
}
