import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/features/parent_zone/domain/models/background_settings.dart';
import 'package:kids_am/features/parent_zone/presentation/providers/background_settings_provider.dart';

class BackgroundCustomizerDialog extends ConsumerStatefulWidget {
  const BackgroundCustomizerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const BackgroundCustomizerDialog(),
    );
  }

  @override
  ConsumerState<BackgroundCustomizerDialog> createState() =>
      _BackgroundCustomizerDialogState();
}

class _BackgroundCustomizerDialogState
    extends ConsumerState<BackgroundCustomizerDialog> {
  ScreenSlot? _selectedSlotForPicker;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(backgroundSettingsProvider);
    final notifier = ref.read(backgroundSettingsProvider.notifier);
    final effectiveDrawings = settings.getEffectiveDrawings();

    // Determinar qué slots están bloqueados por dibujos grandes para evitar que se pisen
    final blockedSlots = <ScreenSlot, String>{};
    for (final entry in settings.slotAssignments.entries) {
      final item = BackgroundCatalog.items[entry.value];
      if (item != null && item.isLarge && item.blocksSlot != null) {
        blockedSlots[item.blocksSlot!] = item.name;
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.dashboard_customize_rounded,
                      color: AppColors.primaryBlue, size: 28),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Lugares Fijos del Fondo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Elige qué dibujo aparece en cada lugar de la pantalla. Si seleccionas un dibujo grande, el lugar que pisaría se bloqueará automáticamente para que nunca se superpongan.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.3),
              ),
              const SizedBox(height: 16),

              // Maqueta visual del celular con los 6 lugares fijos
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: settings.colorTheme.colors,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Fila Superior
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSlotCard(
                                    slot: ScreenSlot.topLeft,
                                    currentEmoji: effectiveDrawings[ScreenSlot.topLeft],
                                    blockedBy: blockedSlots[ScreenSlot.topLeft],
                                    onTap: () => _openPickerForSlot(ScreenSlot.topLeft),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildSlotCard(
                                    slot: ScreenSlot.topRight,
                                    currentEmoji: effectiveDrawings[ScreenSlot.topRight],
                                    blockedBy: blockedSlots[ScreenSlot.topRight],
                                    onTap: () => _openPickerForSlot(ScreenSlot.topRight),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Fila Media
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSlotCard(
                                    slot: ScreenSlot.midLeft,
                                    currentEmoji: effectiveDrawings[ScreenSlot.midLeft],
                                    blockedBy: blockedSlots[ScreenSlot.midLeft],
                                    onTap: () => _openPickerForSlot(ScreenSlot.midLeft),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildSlotCard(
                                    slot: ScreenSlot.midRight,
                                    currentEmoji: effectiveDrawings[ScreenSlot.midRight],
                                    blockedBy: blockedSlots[ScreenSlot.midRight],
                                    onTap: () => _openPickerForSlot(ScreenSlot.midRight),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Fila Inferior
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSlotCard(
                                    slot: ScreenSlot.bottomLeft,
                                    currentEmoji: effectiveDrawings[ScreenSlot.bottomLeft],
                                    blockedBy: blockedSlots[ScreenSlot.bottomLeft],
                                    onTap: () => _openPickerForSlot(ScreenSlot.bottomLeft),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildSlotCard(
                                    slot: ScreenSlot.bottomRight,
                                    currentEmoji: effectiveDrawings[ScreenSlot.bottomRight],
                                    blockedBy: blockedSlots[ScreenSlot.bottomRight],
                                    onTap: () => _openPickerForSlot(ScreenSlot.bottomRight),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (_selectedSlotForPicker != null) ...[
                        const SizedBox(height: 16),
                        _buildDrawingSelector(
                          slot: _selectedSlotForPicker!,
                          notifier: notifier,
                          currentAssignedId: settings.slotAssignments[_selectedSlotForPicker!],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      notifier.resetToDefault();
                      setState(() => _selectedSlotForPicker = null);
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Restaurar Posiciones'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Guardar y Salir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPickerForSlot(ScreenSlot slot) {
    setState(() {
      _selectedSlotForPicker = (_selectedSlotForPicker == slot) ? null : slot;
    });
  }

  Widget _buildSlotCard({
    required ScreenSlot slot,
    required String? currentEmoji,
    required String? blockedBy,
    required VoidCallback onTap,
  }) {
    final isBlocked = blockedBy != null;
    final isSelected = _selectedSlotForPicker == slot;

    return InkWell(
      onTap: isBlocked ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isBlocked
              ? Colors.grey.shade200.withValues(alpha: 0.8)
              : (isSelected
                  ? AppColors.primaryBlue.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.85)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isBlocked
                ? Colors.grey.shade400
                : (isSelected ? AppColors.primaryBlue : Colors.grey.shade300),
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              slot.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isBlocked ? Colors.grey.shade600 : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            if (isBlocked) ...[
              const Icon(Icons.block_rounded, color: Colors.redAccent, size: 26),
              const SizedBox(height: 4),
              Text(
                'Bloqueado\npor $blockedBy',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9.5, color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ] else ...[
              Text(
                currentEmoji ?? '➕ Elegir',
                style: TextStyle(
                  fontSize: currentEmoji != null ? 28 : 12,
                  color: currentEmoji != null ? Colors.black : AppColors.primaryBlue,
                  fontWeight: currentEmoji == null ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawingSelector({
    required ScreenSlot slot,
    required BackgroundSettingsNotifier notifier,
    required String? currentAssignedId,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seleccionar dibujo para: ${slot.label}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryBlue),
              ),
              if (currentAssignedId != null)
                TextButton(
                  onPressed: () {
                    notifier.assignSlot(slot, null);
                    setState(() {});
                  },
                  child: const Text('Quitar dibujo', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BackgroundCatalog.items.entries.map((entry) {
              final id = entry.key;
              final info = entry.value;
              final isAssigned = currentAssignedId == id;

              return InkWell(
                onTap: () {
                  notifier.assignSlot(slot, id);
                  setState(() {});
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isAssigned
                        ? AppColors.primaryBlue.withValues(alpha: 0.2)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAssigned ? AppColors.primaryBlue : Colors.grey.shade300,
                      width: isAssigned ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(info.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(
                        info.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isAssigned ? FontWeight.bold : FontWeight.normal,
                          color: info.isLarge ? Colors.deepPurple : AppColors.textDark,
                        ),
                      ),
                      if (info.isLarge) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.star, size: 12, color: Colors.deepPurple),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
