class AppVersion {
  static const String currentVersion = '1.0.4';
  static const int currentVersionCode = 5;

  /// Calcula la siguiente versión según la regla:
  /// 1.0.0 -> 1.0.1 ... hasta 1.0.9 -> 1.1.0
  static String getNextVersion(String version) {
    final clean = version.replaceAll('v', '').trim();
    final parts = clean.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    int major = parts.isNotEmpty ? parts[0] : 1;
    int minor = parts.length > 1 ? parts[1] : 0;
    int patch = parts.length > 2 ? parts[2] : 0;

    if (patch < 9) {
      patch += 1;
    } else {
      patch = 0;
      minor += 1;
    }
    return '$major.$minor.$patch';
  }

  /// Retorna el nombre del archivo APK estándar para una versión determinada
  static String getApkFileName(String version) {
    final clean = version.replaceAll('v', '').trim();
    return 'KidsAm-installer-v$clean.apk';
  }

  static bool isNewerVersion(String remoteVersion, int remoteVersionCode) {
    // Si viene un versionCode válido (> 0), comprobamos primero
    if (remoteVersionCode > 0) {
      if (remoteVersionCode > currentVersionCode) return true;
      if (remoteVersionCode < currentVersionCode) return false;
    }

    // Comparación semántica por partes (ej: 1.0.4 > 1.0.3)
    final localParts = currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final remoteParts = remoteVersion.replaceAll('v', '').split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final loc = i < localParts.length ? localParts[i] : 0;
      final rem = i < remoteParts.length ? remoteParts[i] : 0;
      if (rem > loc) return true;
      if (rem < loc) return false;
    }
    return false;
  }
}
