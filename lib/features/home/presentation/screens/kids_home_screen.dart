import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/core/services/teacher_voice_service.dart';
import 'package:kids_am/core/widgets/playful_background.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';
import 'package:kids_am/features/rewards/presentation/widgets/rewards_shop_dialog.dart';

class KidsHomeScreen extends ConsumerStatefulWidget {
  const KidsHomeScreen({super.key});

  // Controla que el saludo con el nombre solo se dé UNA VEZ por sesión al abrir la app
  static bool hasGreetedSession = false;

  @override
  ConsumerState<KidsHomeScreen> createState() => _KidsHomeScreenState();
}

class _KidsHomeScreenState extends ConsumerState<KidsHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialGreeting();
    });
  }

  void _checkInitialGreeting() {
    if (!KidsHomeScreen.hasGreetedSession) {
      KidsHomeScreen.hasGreetedSession = true;
      final profile = ref.read(childProfileProvider);
      final greeting = '¡Hola ${profile.name}! ¡Qué bueno que volviste! Elige tu aventura de hoy.';
      TeacherVoiceService.instance.speak(greeting);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(childProfileProvider);

    return Scaffold(
      body: PlayfulBackground(
        child: SafeArea(
          child: Column(
          children: [
            // Header con Perfil, Estrellas / Tienda y botón de Padres
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Avatar del Niño
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.sunnyYellow,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sunnyYellow.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.face_5, size: 34, color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Nombre y Nivel en Expanded
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '¡Hola, ${profile.name}!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Explorador Nivel ${profile.mathLevel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Botón Interactivo de Estrellas y Canje de Premios
                  GestureDetector(
                    onTap: () => RewardsShopDialog.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.sunnyYellow,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.orange, size: 22),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.totalStars}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('🎁', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Acceso a Zona Parental
                  IconButton(
                    onPressed: () => context.push('/parent-gate'),
                    icon: const Icon(Icons.lock, color: AppColors.textMuted, size: 26),
                    tooltip: 'Zona Padres',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Título de la aventura
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Elige tu Aventura 🚀',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Cuadrícula interactiva de mundos
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.84,
                children: [
                  _WorldCard(
                    title: 'Mundo Matemático',
                    subtitle: 'Nivel ${profile.mathLevel} de 10',
                    badgeText: 'Conteo y Sumas',
                    icon: Icons.calculate_rounded,
                    gradientColors: const [Color(0xFFFF9233), Color(0xFFFFB347)],
                    onTap: () => context.push('/games/math'),
                  ),
                  _WorldCard(
                    title: 'Mini-Ajedrez',
                    subtitle: 'Misión ${profile.chessLevel} de 6',
                    badgeText: 'Ajedrez Mágico',
                    icon: Icons.castle_rounded,
                    gradientColors: const [Color(0xFF8E44AD), Color(0xFFBA68C8)],
                    onTap: () => context.push('/games/chess'),
                  ),
                  _WorldCard(
                    title: 'Rompecabezas',
                    subtitle: 'Nivel ${profile.puzzleLevel} de 5',
                    badgeText: 'Puzles y Figuras',
                    icon: Icons.extension_rounded,
                    gradientColors: const [Color(0xFF43C651), Color(0xFF2ECC71)],
                    onTap: () => context.push('/games/puzzle'),
                  ),
                  _WorldCard(
                    title: 'Cine Divertido',
                    subtitle: 'Videos y Música',
                    badgeText: 'Sin Anuncios',
                    icon: Icons.play_circle_fill_rounded,
                    gradientColors: const [Color(0xFF3498DB), Color(0xFF5DADE2)],
                    onTap: () => context.push('/videos'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _WorldCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _WorldCard({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withValues(alpha: 0.28),
              child: Icon(icon, size: 34, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
