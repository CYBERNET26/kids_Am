import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_am/core/constants/app_colors.dart';
import 'package:kids_am/features/profile/presentation/providers/profile_provider.dart';

class KidsHomeScreen extends ConsumerWidget {
  const KidsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(childProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header con Perfil, Estrellas y botón de Padres
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Avatar y Nombre del Niño
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.sunnyYellow,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sunnyYellow.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.face_5, size: 36, color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, ${profile.name}!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Explorador Nivel ${profile.mathLevel}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Contador de Estrellas
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                        const Icon(Icons.star, color: Colors.orange, size: 26),
                        const SizedBox(width: 6),
                        Text(
                          '${profile.totalStars}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Acceso a Zona Parental
                  IconButton(
                    onPressed: () => context.push('/parent-gate'),
                    icon: const Icon(Icons.lock, color: AppColors.textMuted, size: 28),
                    tooltip: 'Zona Padres',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Título de la aventura
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Elige tu Aventura de Hoy 🚀',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Cuadrícula interactiva de mundos
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: [
                  _WorldCard(
                    title: 'Mundo Matemático',
                    subtitle: 'Nivel ${profile.mathLevel}',
                    badgeText: 'Sumas y Restas',
                    icon: Icons.calculate,
                    gradientColors: const [Color(0xFFFF9233), Color(0xFFFFD15C)],
                    onTap: () => context.push('/games/math'),
                  ),
                  _WorldCard(
                    title: 'Mini-Ajedrez',
                    subtitle: 'Nivel ${profile.chessLevel}',
                    badgeText: 'Misiones 4x4',
                    icon: Icons.castle,
                    gradientColors: const [Color(0xFF8E44AD), Color(0xFFBA68C8)],
                    onTap: () => context.push('/games/chess'),
                  ),
                  _WorldCard(
                    title: 'Rompecabezas',
                    subtitle: 'Nivel ${profile.puzzleLevel}',
                    badgeText: '${profile.puzzleLevel == 1 ? "4" : profile.puzzleLevel == 2 ? "9" : "16"} piezas',
                    icon: Icons.extension,
                    gradientColors: const [Color(0xFF5CD85A), Color(0xFF2ECC71)],
                    onTap: () => context.push('/games/puzzle'),
                  ),
                  _WorldCard(
                    title: 'Cine Divertido',
                    subtitle: 'Videos Seguros',
                    badgeText: 'Sin Anuncios',
                    icon: Icons.play_circle_fill,
                    gradientColors: const [Color(0xFF4A90E2), Color(0xFF5DADE2)],
                    onTap: () => context.push('/videos'),
                  ),
                ],
              ),
            ),
          ],
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
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  child: Icon(icon, size: 36, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

