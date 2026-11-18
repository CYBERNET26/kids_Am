import 'package:kids_am/core/constants/app_version.dart';

class AppUpdateInfo {
  final String version;
  final int versionCode;
  final String title;
  final String releaseDate;
  final String changelog;
  final String apkFileName;
  final String downloadUrl;
  final bool isUpdateAvailable;

  const AppUpdateInfo({
    required this.version,
    required this.versionCode,
    required this.title,
    this.releaseDate = '',
    required this.changelog,
    this.apkFileName = 'KidsAm-Installer-v1.0.0.apk',
    required this.downloadUrl,
    required this.isUpdateAvailable,
  });

  factory AppUpdateInfo.fromMap(Map<String, dynamic> map) {
    final version = (map['version'] as String? ?? '1.0.0').replaceAll('v', '').trim();
    final versionCode = (map['versionCode'] as num?)?.toInt() ?? 1;
    final isNewer = AppVersion.isNewerVersion(version, versionCode);

    return AppUpdateInfo(
      version: version,
      versionCode: versionCode,
      title: map['title'] as String? ?? 'Nueva versión disponible',
      releaseDate: map['releaseDate'] as String? ?? '',
      changelog: map['changelog'] as String? ?? 'Mejoras y correcciones generales.',
      apkFileName: map['apkFileName'] as String? ?? AppVersion.getApkFileName(version),
      downloadUrl: map['downloadUrl'] as String? ?? '',
      isUpdateAvailable: isNewer,
    );
  }

  factory AppUpdateInfo.fromGitHubRelease(Map<String, dynamic> releaseJson) {
    final tagName = releaseJson['tag_name'] as String? ?? 'v1.0.0';
    final cleanVersion = tagName.replaceAll('v', '').trim();
    final title = releaseJson['name'] as String? ?? 'Kids Am $tagName';
    final body = releaseJson['body'] as String? ?? 'Mejoras y actualizaciones generales.';

    String downloadUrl = '';
    String apkName = 'KidsAm-installer-v$cleanVersion.apk';

    final assets = releaseJson['assets'] as List<dynamic>?;
    if (assets != null && assets.isNotEmpty) {
      // Buscar primero el asset que coincida con la versión del tag
      for (final a in assets) {
        final name = a['name'] as String? ?? '';
        if (name.contains(cleanVersion) && name.endsWith('.apk')) {
          apkName = name;
          downloadUrl = (a['browser_download_url'] as String? ?? a['url'] as String? ?? '');
          break;
        }
      }
      // Fallback a cualquier APK en los assets con browser_download_url público
      if (downloadUrl.isEmpty) {
        for (final a in assets) {
          final name = a['name'] as String? ?? '';
          if (name.endsWith('.apk')) {
            apkName = name;
            downloadUrl = (a['browser_download_url'] as String? ?? a['url'] as String? ?? '');
            break;
          }
        }
      }
    }

    if (downloadUrl.isEmpty) {
      downloadUrl = 'https://raw.githubusercontent.com/samuel031069/kids_Am/main/$apkName';
    }

    final isNewer = AppVersion.isNewerVersion(cleanVersion, -1);

    return AppUpdateInfo(
      version: cleanVersion,
      versionCode: -1,
      title: title,
      changelog: body,
      apkFileName: apkName,
      downloadUrl: downloadUrl,
      isUpdateAvailable: isNewer,
    );
  }
}
