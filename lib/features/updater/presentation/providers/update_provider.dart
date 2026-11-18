import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_am/core/constants/update_config.dart';
import 'package:kids_am/features/updater/data/services/app_update_service.dart';
import 'package:kids_am/features/updater/data/services/parent_notification_service.dart';
import 'package:kids_am/features/updater/domain/models/app_update_info.dart';
import 'package:kids_am/features/updater/presentation/widgets/update_dialog.dart';

enum UpdateStatus {
  idle,
  checking,
  updateAvailable,
  upToDate,
  downloading,
  readyToInstall,
  error,
}

class UpdateState {
  final UpdateStatus status;
  final AppUpdateInfo? updateInfo;
  final double downloadProgress;
  final int receivedBytes;
  final int totalBytes;
  final String? errorMessage;
  final String githubToken;
  final bool autoCheckOnStart;
  final DateTime? lastChecked;

  const UpdateState({
    this.status = UpdateStatus.idle,
    this.updateInfo,
    this.downloadProgress = 0.0,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.errorMessage,
    this.githubToken = UpdateConfig.defaultGithubToken,
    this.autoCheckOnStart = true,
    this.lastChecked,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    AppUpdateInfo? updateInfo,
    double? downloadProgress,
    int? receivedBytes,
    int? totalBytes,
    String? errorMessage,
    String? githubToken,
    bool? autoCheckOnStart,
    DateTime? lastChecked,
  }) {
    return UpdateState(
      status: status ?? this.status,
      updateInfo: updateInfo ?? this.updateInfo,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      errorMessage: errorMessage,
      githubToken: githubToken ?? this.githubToken,
      autoCheckOnStart: autoCheckOnStart ?? this.autoCheckOnStart,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

class UpdateNotifier extends Notifier<UpdateState> {
  static const _tokenKey = 'github_pat_token';
  static const _autoCheckKey = 'auto_check_updates_on_start';

  @override
  UpdateState build() {
    _loadPreferences();
    return const UpdateState();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey) ?? UpdateConfig.defaultGithubToken;
    final autoCheck = prefs.getBool(_autoCheckKey) ?? true;
    state = state.copyWith(
      githubToken: savedToken,
      autoCheckOnStart: autoCheck,
    );
  }

  Future<void> setGithubToken(String token) async {
    final clean = token.trim();
    state = state.copyWith(githubToken: clean);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, clean);
  }

  Future<void> setAutoCheckOnStart(bool enabled) async {
    state = state.copyWith(autoCheckOnStart: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoCheckKey, enabled);
  }

  /// Comprueba si hay una actualización disponible en el repositorio de GitHub
  Future<void> checkForUpdates({
    bool isManual = false,
    BuildContext? context,
    String? dismissedVersion,
  }) async {
    state = state.copyWith(status: UpdateStatus.checking, errorMessage: null);

    try {
      final info = await AppUpdateService.checkForUpdate(githubToken: state.githubToken);
      final now = DateTime.now();

      if (info != null && info.isUpdateAvailable) {
        state = state.copyWith(
          status: UpdateStatus.updateAvailable,
          updateInfo: info,
          lastChecked: now,
        );

        // Notificar por correo al padre si aún no fue notificado para esta versión
        ParentNotificationService.notifyParentAboutUpdate(info);

        // Si se pasó un context y no fue cancelado por el padre, mostramos la ventana flotante
        if (context != null && context.mounted) {
          final isDismissed = dismissedVersion != null && dismissedVersion == info.version;
          if (!isDismissed || isManual) {
            UpdateDialog.show(context, info);
          }
        }
      } else {
        state = state.copyWith(
          status: UpdateStatus.upToDate,
          updateInfo: info,
          lastChecked: now,
        );

        if (isManual && context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 ¡Ya tienes instalada la versión más reciente de Kids Am!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Error al comprobar actualizaciones: $e',
      );

      if (isManual && context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo verificar actualizaciones: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Descarga el APK con seguimiento de progreso y ejecuta el instalador del sistema
  Future<void> downloadAndInstall({
    required BuildContext context,
    required AppUpdateInfo info,
  }) async {
    state = state.copyWith(
      status: UpdateStatus.downloading,
      downloadProgress: 0.0,
      receivedBytes: 0,
      totalBytes: 0,
      errorMessage: null,
    );

    try {
      final File downloadedFile = await AppUpdateService.downloadApk(
        downloadUrl: info.downloadUrl,
        fileName: info.apkFileName,
        githubToken: state.githubToken,
        onProgress: (received, total) {
          final progress = total > 0 ? (received / total).clamp(0.0, 1.0) : 0.0;
          state = state.copyWith(
            downloadProgress: progress,
            receivedBytes: received,
            totalBytes: total,
          );
        },
      );

      state = state.copyWith(
        status: UpdateStatus.readyToInstall,
        downloadProgress: 1.0,
      );

      // Lanzar el instalador nativo de Android
      final success = await AppUpdateService.installApk(downloadedFile.path);
      if (!success) {
        throw Exception('El instalador fue cancelado o no se completó.');
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Fallo durante la actualización: $e',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al instalar la actualización: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}

final updateProvider = NotifierProvider<UpdateNotifier, UpdateState>(
  UpdateNotifier.new,
);
