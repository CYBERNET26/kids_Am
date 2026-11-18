import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/features/updater/domain/models/app_update_info.dart';
import 'package:kids_am/features/updater/presentation/providers/update_provider.dart';

class UpdateDialog extends ConsumerWidget {
  final AppUpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  static Future<void> show(BuildContext context, AppUpdateInfo info) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UpdateDialog(updateInfo: info),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateProvider);
    final isDownloading = updateState.status == UpdateStatus.downloading;
    final isReadyToInstall = updateState.status == UpdateStatus.readyToInstall;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono de actualización alegre
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.system_update_rounded,
                    color: AppColors.primaryBlue,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Título exigido por el usuario
              const Text(
                'Actualización disponible',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '¡Hay una nueva versión de Kids Am disponible! (${updateInfo.title})',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Estado de descarga en progreso
              if (isDownloading) ...[
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: updateState.downloadProgress > 0 ? updateState.downloadProgress : null,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(updateState.downloadProgress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryBlue),
                        ),
                        if (updateState.totalBytes > 0)
                          Text(
                            '${(updateState.receivedBytes / (1024 * 1024)).toStringAsFixed(1)} MB / ${(updateState.totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          )
                        else
                          const Text('Descargando...', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ] else if (isReadyToInstall) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
                      SizedBox(width: 8),
                      Text(
                        '¡Descarga lista! Abriendo instalador...',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Los 3 botones requeridos: Detalles, Cancelar y Aceptar
              Row(
                children: [
                  // Botón 1: Detalles
                  OutlinedButton(
                    onPressed: () => _showChangelogDetailsDialog(context, updateInfo),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Detalles',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),

                  // Botón 2: Cancelar
                  if (!isDownloading) ...[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Botón 3: Aceptar
                  ElevatedButton(
                    onPressed: isDownloading
                        ? null
                        : () {
                            ref.read(updateProvider.notifier).downloadAndInstall(
                                  context: context,
                                  info: updateInfo,
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.playfulGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    child: Text(
                      isDownloading ? 'Descargando...' : 'Aceptar',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangelogDetailsDialog(BuildContext context, AppUpdateInfo info) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: AppColors.primaryBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Detalles de la versión ${info.version}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 420),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Todos los cambios, agregados y mejoras en esta versión:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.softBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      info.changelog,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }
}
