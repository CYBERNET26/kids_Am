class AppVersion {
  static const String currentVersion = '1.0.0';
  static const int currentVersionCode = 1;

  static bool isNewerVersion(String remoteVersion, int remoteVersionCode) {
    if (remoteVersionCode > currentVersionCode) return true;
    if (remoteVersionCode < currentVersionCode) return false;

    // Comparación semántica (ej: 1.0.1 > 1.0.0)
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
