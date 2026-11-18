import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:kids_am/core/constants/update_config.dart';
import 'package:kids_am/features/updater/domain/models/app_update_info.dart';

class AppUpdateService {
  static const MethodChannel _installerChannel =
      MethodChannel('com.kidsam.kids_am/app_installer');

  /// Comprueba en GitHub si existe una nueva versión disponible
  static Future<AppUpdateInfo?> checkForUpdate({String? githubToken}) async {
    final token = (githubToken != null && githubToken.trim().isNotEmpty)
        ? githubToken.trim()
        : UpdateConfig.defaultGithubToken.trim();

    AppUpdateInfo? latestFound;

    // 1. Intentar a través de raw.githubusercontent.com (version.json directo)
    try {
      final rawInfo = await _checkRawVersionJson(token);
      if (rawInfo != null) {
        if (rawInfo.isUpdateAvailable) return rawInfo;
        latestFound = rawInfo;
      }
    } catch (_) {}

    // 2. Intentar a través de GitHub Releases API (releases/latest)
    try {
      final releaseInfo = await _checkGitHubReleases(token);
      if (releaseInfo != null) {
        if (releaseInfo.isUpdateAvailable) return releaseInfo;
        latestFound ??= releaseInfo;
      }
    } catch (_) {}

    // 3. Intentar a través de la API de contenido (contents/version.json)
    try {
      final contentInfo = await _checkGitHubContentsVersion(token);
      if (contentInfo != null) {
        if (contentInfo.isUpdateAvailable) return contentInfo;
        latestFound ??= contentInfo;
      }
    } catch (_) {}

    return latestFound;
  }

  static Future<AppUpdateInfo?> _checkGitHubReleases(String token) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(UpdateConfig.releasesApiUrl));
      request.headers.set('User-Agent', 'KidsAm-Updater');
      request.headers.set('Accept', 'application/vnd.github+json');
      if (token.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $token');
      }

      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final jsonMap = json.decode(body) as Map<String, dynamic>;
        return AppUpdateInfo.fromGitHubRelease(jsonMap);
      }
    } finally {
      client.close();
    }
    return null;
  }

  static Future<AppUpdateInfo?> _checkGitHubContentsVersion(String token) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(UpdateConfig.versionJsonApiUrl));
      request.headers.set('User-Agent', 'KidsAm-Updater');
      request.headers.set('Accept', 'application/vnd.github+json');
      if (token.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $token');
      }

      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final jsonMap = json.decode(body) as Map<String, dynamic>;
        if (jsonMap.containsKey('content')) {
          final rawBase64 = (jsonMap['content'] as String).replaceAll('\n', '').trim();
          final decodedString = utf8.decode(base64.decode(rawBase64));
          final versionMap = json.decode(decodedString) as Map<String, dynamic>;
          return AppUpdateInfo.fromMap(versionMap);
        }
      }
    } finally {
      client.close();
    }
    return null;
  }

  static Future<AppUpdateInfo?> _checkRawVersionJson(String token) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(UpdateConfig.rawVersionJsonUrl));
      request.headers.set('User-Agent', 'KidsAm-Updater');
      if (token.isNotEmpty) {
        request.headers.set('Authorization', 'token $token');
      }

      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final versionMap = json.decode(body) as Map<String, dynamic>;
        return AppUpdateInfo.fromMap(versionMap);
      }
    } finally {
      client.close();
    }
    return null;
  }

  /// Descarga el APK con seguimiento de progreso en tiempo real
  static Future<File> downloadApk({
    required String downloadUrl,
    required String fileName,
    String? githubToken,
    required void Function(int receivedBytes, int totalBytes) onProgress,
  }) async {
    final token = (githubToken != null && githubToken.trim().isNotEmpty)
        ? githubToken.trim()
        : UpdateConfig.defaultGithubToken.trim();

    final targetDir = Directory.systemTemp;
    final targetFile = File('${targetDir.path}/$fileName');
    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    final client = HttpClient();
    try {
      var currentUri = Uri.parse(downloadUrl);
      HttpClientResponse response;

      // Seguimiento de redirecciones manual para no pasar headers de GitHub a dominios externos (ej. AWS S3)
      while (true) {
        final request = await client.getUrl(currentUri);
        request.headers.set('User-Agent', 'KidsAm-Updater');

        // Si es una URL de la API de GitHub o raw.github, mandamos el token
        if (currentUri.host.contains('github.com') ||
            currentUri.host.contains('githubusercontent.com')) {
          if (token.isNotEmpty) {
            request.headers.set('Authorization', 'Bearer $token');
          }
          if (downloadUrl.contains('/releases/assets/')) {
            request.headers.set('Accept', 'application/octet-stream');
          }
        }

        response = await request.close();
        if (response.isRedirect) {
          final location = response.headers.value(HttpHeaders.locationHeader);
          if (location != null) {
            currentUri = Uri.parse(location);
            continue;
          }
        }
        break;
      }

      if (response.statusCode != 200) {
        throw Exception(
            'Error al descargar actualización (Código HTTP ${response.statusCode})');
      }

      final totalBytes = response.contentLength;
      int receivedBytes = 0;
      final sink = targetFile.openWrite();

      await for (final chunk in response) {
        receivedBytes += chunk.length;
        sink.add(chunk);
        onProgress(receivedBytes, totalBytes);
      }

      await sink.flush();
      await sink.close();

      return targetFile;
    } finally {
      client.close();
    }
  }

  /// Ejecuta la instalación del archivo APK descargado a través del FileProvider nativo
  static Future<bool> installApk(String filePath) async {
    try {
      final success = await _installerChannel.invokeMethod<bool>(
        'installApk',
        {'filePath': filePath},
      );
      return success ?? false;
    } on PlatformException catch (e) {
      throw Exception('Fallo al invocar el instalador de Android: ${e.message}');
    }
  }
}
