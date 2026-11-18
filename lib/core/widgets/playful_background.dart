import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_am/features/parent_zone/domain/models/background_settings.dart';
import 'package:kids_am/features/parent_zone/presentation/providers/background_settings_provider.dart';

class PlayfulBackground extends ConsumerWidget {
  final Widget child;

  const PlayfulBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(backgroundSettingsProvider);
    final drawings = settings.getEffectiveDrawings();
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        // Fondo con el color/degradado configurado por el padre
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: settings.colorTheme.colors,
            ),
          ),
        ),

        // Dibujos decorativos en lugares fijos con prevención de solapamientos
        if (drawings.containsKey(ScreenSlot.topLeft))
          Positioned(
            top: 28,
            left: 20,
            child: _DecorativeItem(
              icon: drawings[ScreenSlot.topLeft]!,
              size: 36,
              opacity: 0.14,
            ),
          ),

        if (drawings.containsKey(ScreenSlot.topRight))
          Positioned(
            top: 28,
            right: 20,
            child: _DecorativeItem(
              icon: drawings[ScreenSlot.topRight]!,
              size: 36,
              opacity: 0.14,
            ),
          ),

        if (drawings.containsKey(ScreenSlot.midLeft))
          Positioned(
            top: size.height * 0.38,
            left: 16,
            child: _DecorativeItem(
              icon: drawings[ScreenSlot.midLeft]!,
              size: 34,
              opacity: 0.13,
            ),
          ),

        if (drawings.containsKey(ScreenSlot.midRight))
          Positioned(
            top: size.height * 0.38,
            right: 16,
            child: _DecorativeItem(
              icon: drawings[ScreenSlot.midRight]!,
              size: 34,
              opacity: 0.13,
            ),
          ),

        if (drawings.containsKey(ScreenSlot.bottomLeft))
          Positioned(
            bottom: 28,
            left: 20,
            child: _DecorativeItem(
              icon: drawings[ScreenSlot.bottomLeft]!,
              size: 36,
              opacity: 0.14,
            ),
          ),

        if (drawings.containsKey(ScreenSlot.bottomRight))
          Positioned(
            bottom: 28,
            right: 20,
            child: _DecorativeItem(
              icon: drawings[ScreenSlot.bottomRight]!,
              size: 36,
              opacity: 0.14,
            ),
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
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Text(
          icon,
          style: TextStyle(fontSize: size),
        ),
      ),
    );
  }
}
