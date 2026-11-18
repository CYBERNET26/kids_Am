import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/core/widgets/playful_background.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/stories/presentation/providers/stories_provider.dart';

class StoriesCatalogScreen extends ConsumerWidget {
  const StoriesCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesState = ref.watch(storiesProvider);
    final profile = ref.watch(childProfileProvider);

    return Scaffold(
      body: PlayfulBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra Superior
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark),
                      onPressed: () => context.pop(),
                      tooltip: 'Volver',
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rincón de Cuentos 📚',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Historias mágicas y comprensión lectora',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Contador de estrellas
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.sunnyYellow,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.orange, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.totalStars}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Banner Explicativo
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '¡Lee con atención! Al final de cada cuento hay preguntas divertidas. ¡Ganas +${storiesState.starsPerCorrectQuestion} estrella${storiesState.starsPerCorrectQuestion > 1 ? 's' : ''} por cada respuesta correcta!',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Lista de Cuentos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: storiesState.stories.length,
                  itemBuilder: (context, index) {
                    final story = storiesState.stories[index];
                    final isCompleted = storiesState.completedStoryIds.contains(story.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isCompleted
                              ? Colors.green.withValues(alpha: 0.6)
                              : Colors.grey.shade200,
                          width: isCompleted ? 2 : 1,
                        ),
                      ),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => context.push('/stories/read', extra: story),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Avatar / Emoji
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  story.emoji,
                                  style: const TextStyle(fontSize: 34),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Información del cuento
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      story.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      story.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '⏱️ ${story.readingTimeMinutes} min',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '❓ ${story.questions.length} preguntas',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        if (isCompleted)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.check_circle_rounded, size: 13, color: Colors.green),
                                                SizedBox(width: 3),
                                                Text(
                                                  '¡Leído!',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.grey,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
