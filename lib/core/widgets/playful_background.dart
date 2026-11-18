import 'package:flutter/material.dart';

class PlayfulBackground extends StatelessWidget {
  final Widget child;

  const PlayfulBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradiente alegre y luminoso que no satura la vista
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE9F5FF), // Celeste cielo suave
                Color(0xFFFFF9EE), // Amarillo crema luminoso
                Color(0xFFFBF1F8), // Toque pastel mágico
              ],
            ),
          ),
        ),

        // Elementos decorativos infantiles flotantes con opacidad suave
        Positioned(
          top: 30,
          right: 25,
          child: _DecorativeItem(icon: '⭐', size: 32, opacity: 0.12),
        ),
        Positioned(
          top: 140,
          left: 18,
          child: _DecorativeItem(icon: '☁️', size: 40, opacity: 0.12),
        ),
        Positioned(
          top: 260,
          right: 20,
          child: _DecorativeItem(icon: '✨', size: 28, opacity: 0.10),
        ),
        Positioned(
          bottom: 220,
          left: 15,
          child: _DecorativeItem(icon: '🎈', size: 34, opacity: 0.11),
        ),
        Positioned(
          bottom: 120,
          right: 30,
          child: _DecorativeItem(icon: '🚀', size: 36, opacity: 0.10),
        ),
        Positioned(
          bottom: 30,
          left: 35,
          child: _DecorativeItem(icon: '🌟', size: 30, opacity: 0.12),
        ),

        // Contenido interactivo en primer plano
        child,
      ],
    );
  }
}

class _DecorativeItem extends StatelessWidget {
  final String icon;
  final double size;
  final double opacity;

  const _DecorativeItem({
    required this.icon,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Text(
        icon,
        style: TextStyle(fontSize: size),
      ),
    );
  }
}
