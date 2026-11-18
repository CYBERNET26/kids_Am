import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_am/features/tutor/data/services/gemini_ai_tutor_service.dart';
import 'package:kids_am/features/tutor/data/services/hybrid_tutor_coordinator.dart';

class TutorSettingsState {
  final bool isAiEnabled;
  final String apiKey;
  final bool isValidatingKey;
  final bool? keyValidationSuccess;
  final String? validationMessage;

  const TutorSettingsState({
    this.isAiEnabled = false,
    this.apiKey = '',
    this.isValidatingKey = false,
    this.keyValidationSuccess,
    this.validationMessage,
  });

  TutorSettingsState copyWith({
    bool? isAiEnabled,
    String? apiKey,
    bool? isValidatingKey,
    bool? keyValidationSuccess,
    String? validationMessage,
  }) {
    return TutorSettingsState(
      isAiEnabled: isAiEnabled ?? this.isAiEnabled,
      apiKey: apiKey ?? this.apiKey,
      isValidatingKey: isValidatingKey ?? this.isValidatingKey,
      keyValidationSuccess: keyValidationSuccess,
      validationMessage: validationMessage,
    );
  }

  HybridTutorCoordinator get coordinator => HybridTutorCoordinator(
        isAiEnabled: isAiEnabled,
        apiKey: apiKey,
      );
}

class TutorSettingsNotifier extends Notifier<TutorSettingsState> {
  static const _aiEnabledKey = 'tutor_ai_enabled';
  static const _apiKeyStorageKey = 'tutor_gemini_api_key';

  @override
  TutorSettingsState build() {
    _loadSettings();
    return const TutorSettingsState();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_aiEnabledKey) ?? false;
      final key = prefs.getString(_apiKeyStorageKey) ?? '';

      state = state.copyWith(
        isAiEnabled: enabled,
        apiKey: key,
      );
    } catch (_) {}
  }

  Future<void> toggleAiEnabled(bool enabled) async {
    state = state.copyWith(isAiEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiEnabledKey, enabled);
  }

  Future<void> saveApiKey(String key) async {
    final clean = GeminiAITutorService.cleanKey(key);
    state = state.copyWith(apiKey: clean);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyStorageKey, clean);
  }

  Future<bool> testApiKey(String key) async {
    state = state.copyWith(isValidatingKey: true, keyValidationSuccess: null);

    final clean = GeminiAITutorService.cleanKey(key);
    final result = await GeminiAITutorService.validateApiKey(clean);

    state = state.copyWith(
      isValidatingKey: false,
      keyValidationSuccess: result.isValid,
      validationMessage: result.message,
    );

    if (result.isValid) {
      await saveApiKey(clean);
    }

    return result.isValid;
  }
}

final tutorProvider = NotifierProvider<TutorSettingsNotifier, TutorSettingsState>(
  TutorSettingsNotifier.new,
);
