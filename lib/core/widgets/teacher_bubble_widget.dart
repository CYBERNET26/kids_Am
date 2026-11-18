import 'package:flutter/material.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/core/services/teacher_voice_service.dart';

class TeacherBubbleWidget extends StatelessWidget {
  final String speechText;
  final bool isCelebration;
  final bool isTip;
  final VoidCallback? onReplay;

  const TeacherBubbleWidget({
    super.key,
    required this.speechText,
    this.isCelebration = false,
    this.isTip = false,
    this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isCelebration
        ? const Color(0xFFE8F8F5)
        : (isTip ? const Color(0xFFFEF9E7) : Colors.white);
    final borderColor = isCelebration
        ? AppColors.playfulGreen
        : (isTip ? Colors.orange : AppColors.primaryBlue.withValues(alpha: 0.3));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar de la Maestra
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCelebration
                  ? AppColors.playfulGreen.withValues(alpha: 0.2)
                  : AppColors.sunnyYellow.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Text(
              isCelebration ? '🌟' : (isTip ? '💡' : '👩‍🏫'),
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: 12),
          // Globo de diálogo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      isCelebration
                          ? '¡Profe Sofía celebra!'
                          : (isTip ? 'Pista de la Profe Sofía:' : 'Profe Sofía dice:'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCelebration
                            ? AppColors.playfulGreen
                            : (isTip ? Colors.orange.shade800 : AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  speechText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          // Botón para repetir la voz
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue),
            tooltip: 'Repetir explicación',
            onPressed: () {
              if (onReplay != null) {
                onReplay!();
              } else {
                TeacherVoiceService.instance.speak(speechText);
              }
            },
          ),
        ],
      ),
    );
  }
}
