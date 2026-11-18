import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:kids_am/features/parent_zone/domain/models/custom_exercise.dart';

class CustomExercisesNotifier extends Notifier<List<CustomExercise>> {
  static const String _storageKey = 'custom_parent_exercises_v1';
  static const _uuid = Uuid();

  static final List<CustomExercise> _defaultExercises = [
    CustomExercise(
      id: 'custom_ex_1',
      operation: MathOperation.addition,
      firstNum: 4,
      secondNum: 3,
      correctResult: 7,
      note: '¡Desafío de Mamá para la merienda!',
      createdAt: DateTime.now(),
    ),
    CustomExercise(
      id: 'custom_ex_2',
      operation: MathOperation.multiplication,
      firstNum: 3,
      secondNum: 2,
      correctResult: 6,
      note: '¡Practiquemos la tabla del 3 con Papá!',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  List<CustomExercise> build() {
    _loadFromPrefs();
    return _defaultExercises;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = json.decode(jsonString);
        final loaded = decoded
            .map((item) => CustomExercise.fromMap(item as Map<String, dynamic>))
            .toList();
        if (loaded.isNotEmpty) {
          state = loaded;
        }
      }
    } catch (_) {}
  }

  Future<void> _saveToPrefs(List<CustomExercise> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(list.map((e) => e.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  void addExercise({
    required MathOperation operation,
    required int firstNum,
    required int secondNum,
    required int correctResult,
    String note = '',
  }) {
    final newExercise = CustomExercise(
      id: _uuid.v4(),
      operation: operation,
      firstNum: firstNum,
      secondNum: secondNum,
      correctResult: correctResult,
      note: note,
      createdAt: DateTime.now(),
    );
    final updated = [newExercise, ...state];
    state = updated;
    _saveToPrefs(updated);
  }

  void updateExercise({
    required String id,
    required MathOperation operation,
    required int firstNum,
    required int secondNum,
    required int correctResult,
    String note = '',
  }) {
    final updated = state.map((item) {
      if (item.id == id) {
        return item.copyWith(
          operation: operation,
          firstNum: firstNum,
          secondNum: secondNum,
          correctResult: correctResult,
          note: note,
        );
      }
      return item;
    }).toList();
    state = updated;
    _saveToPrefs(updated);
  }

  void deleteExercise(String id) {
    final updated = state.where((item) => item.id != id).toList();
    state = updated;
    _saveToPrefs(updated);
  }

  void markCompleted(String id, {bool completed = true}) {
    final updated = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isCompleted: completed);
      }
      return item;
    }).toList();
    state = updated;
    _saveToPrefs(updated);
  }
}

final customExercisesProvider =
    NotifierProvider<CustomExercisesNotifier, List<CustomExercise>>(
  CustomExercisesNotifier.new,
);
