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
        // 1. Fondo con el color/degradado configurado por el padre
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: settings.colorTheme.colors,
            ),
          ),
        ),

        // 2. Dibujos decorativos en lugares fijos (con visibilidad nítida y alegre ~0.40)
        if (drawings.containsKey(ScreenSlot.topLeft))
          Positioned(
            top: 24,
            left: 18,
            child: _DecorativeItem(
              icon: drawings[ScreenSlot.topLeft]!,
              size: 40,
              opacity: 0.40,
            ),
          ),

        if (drawings.containsKey(ScreenSlot.topRight))
          Positioned(
            top: 24,
            right: 18,
            child: _DecorativeItem(
              icon: drawings[ScreenSlot.topRight]!,
              size: 40,
              opacity: 0.40,
            ),
          ),

        if (drawings.containsKey(ScreenSlot.midLeft))
          Positioned(
            top: size.height * 0.38,
            left: 14,
            child: _DecorativeItem(
              icon: drawings[ScreenSlot.midLeft]!,
              size: 38,
              opacity: 0.38,
            ),
          ),

        if (drawings.containsKey(ScreenSlot.midRight))
          Positioned(
            top: size.height * 0.38,
            right: 14,
            child: _DecorativeItem(
              icon: drawings[ScreenSlot.midRight]!,
              size: 38,
              opacity: 0.38,
            ),
          ),

        if (drawings.containsKey(ScreenSlot.bottomLeft))
          Positioned(
            bottom: 24,
            left: 18,
            child: _DecorativeItem(
              icon: drawings[ScreenSlot.bottomLeft]!,
              size: 40,
              opacity: 0.40,
            ),
          ),

        if (drawings.containsKey(ScreenSlot.bottomRight))
          Positioned(
            bottom: 24,
            right: 18,
            child: _DecorativeItem(
              icon: drawings[ScreenSlot.bottomRight]!,
              size: 40,
              opacity: 0.40,
            ),
          ),

        // 3. Elementos temáticos integrados (el mono colgando, corona, cohete, etc.)
        ..._buildThemedIntegratedDecor(settings.drawingTheme, size),

        // 4. Contenido interactivo en primer plano
        child,
      ],
    );
  }

  List<Widget> _buildThemedIntegratedDecor(
      BackgroundDrawingTheme theme, Size size) {
    switch (theme) {
      case BackgroundDrawingTheme.animales:
        // MONO COLGANDO DE UNA LIANA entre la cabecera y los botones
        return [
          Positioned(
            top: 8,
            right: 48,
            child: IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 22)),
                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: const Text('🌿', style: TextStyle(fontSize: 20)),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: const Text('🐒', style: TextStyle(fontSize: 42)), // ¡El monito colgándose!
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 54,
            child: IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 22)),
                  Transform.translate(
                    offset: const Offset(-4, 4),
                    child: const Text('🦜', style: TextStyle(fontSize: 28)), // Lorito simpático
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 18,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.35,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('🐾', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 4),
                    Text('🐾', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ];

      case BackgroundDrawingTheme.princesas:
        // CORONA REAL, VARITA MÁGICA Y BRILLITOS
        return [
          Positioned(
            top: 10,
            right: 45,
            child: IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('👑', style: TextStyle(fontSize: 34)),
                  Transform.translate(
                    offset: const Offset(8, -4),
                    child: const Text('✨', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 55,
            child: IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🪄', style: TextStyle(fontSize: 32)),
                  Text('✨', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 85,
            left: 20,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.45,
                child: const Text('🎀 🌸', style: TextStyle(fontSize: 22)),
              ),
            ),
          ),
        ];

      case BackgroundDrawingTheme.cohetes:
        // COHETE DESPEGANDO CON ESTELA Y ASTRONAUTA FLOTANDO
        return [
          Positioned(
            top: 12,
            right: 40,
            child: IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 40)),
                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: const Text('💨', style: TextStyle(fontSize: 18)),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: const Text('✨', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 22,
            left: 50,
            child: IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('👨‍🚀', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 4),
                  Text('🪐', style: TextStyle(fontSize: 22)),
                ],
              ),
            ),
          ),
        ];

      case BackgroundDrawingTheme.estrellas:
        // ARCOÍRIS CON NUBECITAS
        return [
          Positioned(
            top: 12,
            right: 48,
            child: IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🌈', style: TextStyle(fontSize: 38)),
                  Text('☁️', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 55,
            child: IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('☀️', style: TextStyle(fontSize: 30)),
                  Text('✨', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
        ];

      case BackgroundDrawingTheme.vehiculos:
        // AVIÓN Y TREN
        return [
          Positioned(
            top: 14,
            right: 42,
            child: IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('✈️', style: TextStyle(fontSize: 36)),
                  Text('💨', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
          Positioned(
            top: 22,
            left: 50,
            child: IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🚗', style: TextStyle(fontSize: 32)),
                  Text('🏁', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
        ];

      case BackgroundDrawingTheme.personalizado:
      case BackgroundDrawingTheme.ninguno:
        return [];
    }
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
