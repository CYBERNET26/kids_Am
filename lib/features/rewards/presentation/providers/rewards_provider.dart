import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_am/features/rewards/domain/models/reward_item.dart';

class RewardsNotifier extends Notifier<List<RewardItem>> {
  static const _storageKey = 'parent_configured_rewards';

  static final List<RewardItem> _defaultRewards = [
    const RewardItem(
      id: 'rew_icecream',
      title: 'Un Helado Delicioso',
      description: 'Elige tu sabor o paleta favorita',
      costStars: 10,
      icon: '🍦',
    ),
    const RewardItem(
      id: 'rew_pizza',
      title: 'Elegir la Cena de Hoy',
      description: 'Pizza, hamburguesas o tu comida favorita',
      costStars: 15,
      icon: '🍕',
    ),
    const RewardItem(
      id: 'rew_park',
      title: 'Salida Especial al Parque',
      description: 'Juegos, hamacas y paseo al aire libre',
      costStars: 20,
      icon: '🎠',
    ),
    const RewardItem(
      id: 'rew_movie',
      title: 'Tarde de Cine y Pochoclos',
      description: 'Ver tu película favorita en familia',
      costStars: 25,
      icon: '🍿',
    ),
    const RewardItem(
      id: 'rew_toy',
      title: 'Premio Sorpresa',
      description: 'Un juguete o libro elegido con papá y mamá',
      costStars: 35,
      icon: '🎁',
    ),
  ];

  @override
  List<RewardItem> build() {
    _loadFromStorage();
    return _defaultRewards;
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List decoded = jsonDecode(jsonString);
        final loaded = decoded.map((e) => RewardItem.fromMap(Map<String, dynamic>.from(e))).toList();
        if (loaded.isNotEmpty) {
          state = loaded;
        }
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage(List<RewardItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(items.map((e) => e.toMap()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (_) {}
  }

  void addReward({
    required String title,
    required int costStars,
    String icon = '🎁',
    String description = '',
  }) {
    final newReward = RewardItem(
      id: 'rew_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      costStars: costStars,
      icon: icon,
    );
    final updated = [...state, newReward];
    state = updated;
    _saveToStorage(updated);
  }

  void updateReward({
    required String id,
    required String title,
    required int costStars,
    required String icon,
    required String description,
  }) {
    final updated = state.map((item) {
      if (item.id == id) {
        return item.copyWith(
          title: title,
          costStars: costStars,
          icon: icon,
          description: description,
        );
      }
      return item;
    }).toList();
    state = updated;
    _saveToStorage(updated);
  }

  void removeReward(String id) {
    final updated = state.where((item) => item.id != id).toList();
    state = updated;
    _saveToStorage(updated);
  }

  void recordRedemption(String id) {
    final updated = state.map((item) {
      if (item.id == id) {
        return item.copyWith(timesRedeemed: item.timesRedeemed + 1);
      }
      return item;
    }).toList();
    state = updated;
    _saveToStorage(updated);
  }

  void restoreDefaults() {
    state = _defaultRewards;
    _saveToStorage(_defaultRewards);
  }
}

final rewardsProvider = NotifierProvider<RewardsNotifier, List<RewardItem>>(
  RewardsNotifier.new,
);
