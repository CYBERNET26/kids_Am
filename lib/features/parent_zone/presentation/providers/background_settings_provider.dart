import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_am/features/parent_zone/domain/models/background_settings.dart';

class BackgroundSettingsNotifier extends Notifier<BackgroundSettings> {
  static const String _storageKey = 'parent_background_settings_v1';

  @override
  BackgroundSettings build() {
    _loadFromPrefs();
    return const BackgroundSettings();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        state = BackgroundSettings.fromJson(jsonString);
      }
    } catch (_) {}
  }

  Future<void> _saveToPrefs(BackgroundSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, settings.toJson());
    } catch (_) {}
  }

  void setColorTheme(BackgroundColorTheme theme) {
    final updated = state.copyWith(colorTheme: theme);
    state = updated;
    _saveToPrefs(updated);
  }

  void setDrawingTheme(BackgroundDrawingTheme theme) {
    final updated = state.copyWith(drawingTheme: theme);
    state = updated;
    _saveToPrefs(updated);
  }

  void assignSlot(ScreenSlot slot, String? itemId) {
    final current = Map<ScreenSlot, String>.from(state.slotAssignments);
    if (itemId == null || itemId.isEmpty) {
      current.remove(slot);
    } else {
      current[slot] = itemId;

      // Si el item asignado es grande, desocupamos el slot que pisaría para que nunca se superpongan
      final item = BackgroundCatalog.items[itemId];
      if (item != null && item.isLarge && item.blocksSlot != null) {
        current.remove(item.blocksSlot!);
      }

      // Además, si algún otro slot ya tenía un dibujo grande que pisaba este slot, limpiamos el slot conflictivo
      for (final otherEntry in current.entries.toList()) {
        if (otherEntry.key != slot) {
          final otherItem = BackgroundCatalog.items[otherEntry.value];
          if (otherItem != null && otherItem.isLarge && otherItem.blocksSlot == slot) {
            current.remove(otherEntry.key);
          }
        }
      }
    }

    final updated = state.copyWith(
      drawingTheme: BackgroundDrawingTheme.personalizado,
      slotAssignments: current,
    );
    state = updated;
    _saveToPrefs(updated);
  }

  void resetToDefault() {
    const updated = BackgroundSettings();
    state = updated;
    _saveToPrefs(updated);
  }
}

final backgroundSettingsProvider =
    NotifierProvider<BackgroundSettingsNotifier, BackgroundSettings>(
  BackgroundSettingsNotifier.new,
);
