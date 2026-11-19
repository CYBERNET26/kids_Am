import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_am/core/constants/update_config.dart';
import 'package:kids_am/core/constants/default_videos.dart';
import 'package:kids_am/features/stories/data/default_stories.dart';
import 'package:kids_am/features/dynamic_content/domain/models/content_bundle.dart';

class DynamicContentResult {
  final bool hasUpdate;
  final int version;
  final String message;
  final ContentBundle? bundle;
  final bool isError;

  const DynamicContentResult({
    required this.hasUpdate,
    required this.version,
    required this.message,
    this.bundle,
    this.isError = false,
  });
}

class DynamicContentService {
  static const String _bundleStorageKey = 'cached_dynamic_content_bundle';
  static const String _bundleVersionKey = 'cached_dynamic_bundle_version';
  static const String _lastCheckedKey = 'cached_dynamic_last_checked';

  /// Obtiene la versión local del bundle de contenido (mínimo 1)
  static Future<int> getLocalBundleVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bundleVersionKey) ?? 1;
  }

  /// Obtiene la fecha/hora de la última sincronización
  static Future<String?> getLastSyncDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCheckedKey);
  }

  /// Carga el paquete de contenido activo (desde la caché local si existe, o valores de fábrica)
  static Future<ContentBundle> loadActiveBundle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_bundleStorageKey);
      if (rawJson != null && rawJson.trim().isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(rawJson);
        return ContentBundle.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('[DynamicContentService] Error leyendo bundle local: $e');
    }

    // Paquete por defecto de fábrica
    return ContentBundle(
      bundleVersion: 1,
      updatedAt: '2026-11-19',
      releaseNotes: 'Contenido base inicial',
      stories: defaultStories,
      videos: defaultEducationalVideos,
    );
  }

  /// Guarda un bundle completo en la memoria persistente del dispositivo
  static Future<void> saveBundleLocally(ContentBundle bundle) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(bundle.toJson());
      await prefs.setString(_bundleStorageKey, jsonString);
      await prefs.setInt(_bundleVersionKey, bundle.bundleVersion);
      await prefs.setString(_lastCheckedKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('[DynamicContentService] Error guardando bundle: $e');
    }
  }

  /// Sincroniza en caliente desde GitHub (descarga ultraligera de unos 20-40 KB en < 1s)
  static Future<DynamicContentResult> syncFromCloud({bool force = false}) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 6);

    try {
      final currentVersion = await getLocalBundleVersion();
      final urlWithTimestamp =
          '${UpdateConfig.rawContentBundleUrl}?t=${DateTime.now().millisecondsSinceEpoch}';

      final request = await client.getUrl(Uri.parse(urlWithTimestamp));
      request.headers.set('User-Agent', 'KidsAm-ContentUpdater');
      request.headers.set('Accept', 'application/json');

      final response = await request.close().timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> jsonMap = jsonDecode(body);
        final remoteBundle = ContentBundle.fromJson(jsonMap);

        // Guardar última fecha comprobada
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastCheckedKey, DateTime.now().toIso8601String());

        if (remoteBundle.bundleVersion > currentVersion || force) {
          await saveBundleLocally(remoteBundle);
          return DynamicContentResult(
            hasUpdate: true,
            version: remoteBundle.bundleVersion,
            message: remoteBundle.releaseNotes.isNotEmpty
                ? remoteBundle.releaseNotes
                : '¡Contenido actualizado en caliente (v${remoteBundle.bundleVersion})!',
            bundle: remoteBundle,
          );
        } else {
          return DynamicContentResult(
            hasUpdate: false,
            version: currentVersion,
            message: 'El contenido ya está al día (Versión $currentVersion).',
            bundle: remoteBundle,
          );
        }
      } else {
        return DynamicContentResult(
          hasUpdate: false,
          version: await getLocalBundleVersion(),
          message: 'El servidor respondió con código ${response.statusCode}.',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('[DynamicContentService] Error de sincronización: $e');
      final currentVersion = await getLocalBundleVersion();
      return DynamicContentResult(
        hasUpdate: false,
        version: currentVersion,
        message: 'No se pudo conectar para sincronizar: $e',
        isError: true,
      );
    } finally {
      client.close();
    }
  }
}
