import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/core/services/teacher_voice_service.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/rewards/domain/models/reward_item.dart';
import 'package:kids_am/features/rewards/presentation/providers/rewards_provider.dart';

class RewardsShopDialog extends ConsumerStatefulWidget {
  const RewardsShopDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const RewardsShopDialog(),
    );
  }

  @override
  ConsumerState<RewardsShopDialog> createState() => _RewardsShopDialogState();
}

class _RewardsShopDialogState extends ConsumerState<RewardsShopDialog> {
  late ConfettiController _confettiController;
  RewardItem? _justClaimedReward;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _claimReward(RewardItem reward) {
    final profile = ref.read(childProfileProvider);
    final success = ref.read(childProfileProvider.notifier).deductStars(reward.costStars);

    if (success) {
      ref.read(rewardsProvider.notifier).recordRedemption(reward.id);
      setState(() {
        _justClaimedReward = reward;
      });
      _confettiController.play();

      final speech = '¡Felicitaciones ${profile.name}! Has canjeado tu premio: ¡${reward.title}! ¡Muéstrale a tus papás para disfrutarlo!';
      TeacherVoiceService.instance.speak(speech);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(childProfileProvider);
    final rewards = ref.watch(rewardsProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 440, maxHeight: 600),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.softBackground,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: _justClaimedReward != null
                ? _buildClaimSuccessView(_justClaimedReward!, profile.name)
                : _buildRewardsListView(rewards, profile.totalStars),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.orange, Colors.green, Colors.pink, Colors.blue, Colors.purple],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsListView(List<RewardItem> rewards, int currentStars) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.sunnyYellow,
              child: Text('🎁', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Premios por Estrellas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, size: 26),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Saldo de estrellas
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              Text(
                'Tienes $currentStars Estrellas',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Lista de premios
        Expanded(
          child: rewards.isEmpty
              ? const Center(
                  child: Text(
                    'Pide a tus papás que agreguen premios en el Control Parental.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index];
                    final canAfford = currentStars >= reward.costStars;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Icono del premio
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.sunnyYellow.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(reward.icon, style: const TextStyle(fontSize: 26)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Título y descripción
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reward.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  if (reward.description.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      reward.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${reward.costStars} estrellas',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botón de Canje
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canAfford ? AppColors.playfulGreen : Colors.grey.shade300,
                                foregroundColor: canAfford ? Colors.white : Colors.grey.shade700,
                                elevation: canAfford ? 2 : 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: canAfford ? () => _claimReward(reward) : null,
                              child: Text(
                                canAfford ? '¡Canjear!' : '-${reward.costStars - currentStars} ⭐',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildClaimSuccessView(RewardItem reward, String childName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.playfulGreen.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(reward.icon, style: const TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          '🎉 ¡Premio Canjeado con Éxito! ⭐',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.playfulGreen,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.playfulGreen, width: 2),
          ),
          child: Column(
            children: [
              Text(
                'Cupón para: $childName',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                reward.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              if (reward.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  reward.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '¡Muéstrale este cupón a tus papás para disfrutar tu premio!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('¡Genial, gracias!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
