class UpdateConfig {
  static const String repoOwner = 'samuel031069';
  static const String repoName = 'kids_Am';
  static const String defaultBranch = 'main';

  // Si el repositorio es privado, GitHub requiere un Personal Access Token (PAT).
  static const String defaultGithubToken = '';

  static String get releasesApiUrl =>
      'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';

  static String get versionJsonApiUrl =>
      'https://api.github.com/repos/$repoOwner/$repoName/contents/version.json?ref=$defaultBranch';

  static String get rawVersionJsonUrl =>
      'https://raw.githubusercontent.com/$repoOwner/$repoName/$defaultBranch/version.json';

  static String get rawApkDownloadUrl =>
      'https://raw.githubusercontent.com/$repoOwner/$repoName/$defaultBranch/KidsAm-installer-v1.0.1.apk';

  static String getApkDownloadUrl(String version) {
    final clean = version.replaceAll('v', '').trim();
    return 'https://raw.githubusercontent.com/$repoOwner/$repoName/$defaultBranch/KidsAm-installer-v$clean.apk';
  }
}
