import 'dart:convert';
import 'package:flutter/material.dart';

enum BackgroundColorTheme {
  original(
    id: 'original',
    name: 'Arcoíris Pastel (Original)',
    colors: [Color(0xFFE9F5FF), Color(0xFFFFF9EE), Color(0xFFFBF1F8)],
    previewColor: Color(0xFFE9F5FF),
  ),
  celeste(
    id: 'celeste',
    name: 'Cielo Azul Calmo',
    colors: [Color(0xFFE3F2FD), Color(0xFFF0F9FF), Color(0xFFFFFFFF)],
    previewColor: Color(0xFF90CAF9),
  ),
  rosa(
    id: 'rosa',
    name: 'Rosa Dulce / Princesas',
    colors: [Color(0xFFFCE4EC), Color(0xFFFFF0F5), Color(0xFFFFFFFF)],
    previewColor: Color(0xFFF48FB1),
  ),
  menta(
    id: 'menta',
    name: 'Verde Menta / Selva',
    colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9), Color(0xFFFFFFFF)],
    previewColor: Color(0xFFA5D6A7),
  ),
  lavanda(
    id: 'lavanda',
    name: 'Lavanda Mágica / Espacio',
    colors: [Color(0xFFEDE7F6), Color(0xFFF3E5F5), Color(0xFFFFFFFF)],
    previewColor: Color(0xFFCE93D8),
  ),
  soleado(
    id: 'soleado',
    name: 'Amarillo Sol Radiante',
    colors: [Color(0xFFFFF8E1), Color(0xFFFFFDE7), Color(0xFFFFFFFF)],
    previewColor: Color(0xFFFFE082),
  ),
  blanco(
    id: 'blanco',
    name: 'Blanco Nube Minimalista',
    colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5), Color(0xFFFFFFFF)],
    previewColor: Color(0xFFEEEEEE),
  );

  final String id;
  final String name;
  final List<Color> colors;
  final Color previewColor;

  const BackgroundColorTheme({
    required this.id,
    required this.name,
    required this.colors,
    required this.previewColor,
  });

  static BackgroundColorTheme fromId(String id) {
    return BackgroundColorTheme.values.firstWhere(
      (e) => e.id == id,
      orElse: () => BackgroundColorTheme.original,
    );
  }
}

enum BackgroundDrawingTheme {
  princesas('princesas', '👑 Princesas y Cuentos Mágicos'),
  animales('animales', '🦁 Animales de la Selva y Granja'),
  cohetes('cohetes', '🚀 Cohetes y Aventura Espacial'),
  estrellas('estrellas', '⭐ Estrellas, Nubes y Arcoíris'),
  vehiculos('vehiculos', '🚗 Autos, Aviones y Barcos'),
  personalizado('personalizado', '🎨 Personalizado (por lugares fijos)'),
  ninguno('ninguno', '🚫 Fondo liso (sin dibujos)');

  final String id;
  final String label;
  const BackgroundDrawingTheme(this.id, this.label);

  static BackgroundDrawingTheme fromId(String id) {
    return BackgroundDrawingTheme.values.firstWhere(
      (e) => e.id == id,
      orElse: () => BackgroundDrawingTheme.originalMix,
    );
  }

  static BackgroundDrawingTheme get originalMix => BackgroundDrawingTheme.estrellas;
}

enum ScreenSlot {
  topLeft('Superior Izquierda'),
  topRight('Superior Derecha'),
  midLeft('Medio Izquierda'),
  midRight('Medio Derecha'),
  bottomLeft('Inferior Izquierda'),
  bottomRight('Inferior Derecha');

  final String label;
  const ScreenSlot(this.label);
}

class BackgroundItemInfo {
  final String emoji;
  final String name;
  final bool isLarge; // Si es grande, ocupa y bloquea el slot adyacente para no pisarse
  final ScreenSlot? blocksSlot; // El slot que no se puede usar si este dibujo está presente

  const BackgroundItemInfo({
    required this.emoji,
    required this.name,
    this.isLarge = false,
    this.blocksSlot,
  });
}

class BackgroundCatalog {
  static const Map<String, BackgroundItemInfo> items = {
    // Princesas
    'corona': BackgroundItemInfo(emoji: '👑', name: 'Corona Real'),
    'princesa': BackgroundItemInfo(emoji: '👸', name: 'Princesa'),
    'varita': BackgroundItemInfo(emoji: '🪄', name: 'Varita Mágica'),
    'joya': BackgroundItemInfo(emoji: '💎', name: 'Joya Brillante'),
    'flor': BackgroundItemInfo(emoji: '🌸', name: 'Flor del Jardín'),
    'gran_castillo': BackgroundItemInfo(
      emoji: '🏰',
      name: 'Gran Castillo (Grande)',
      isLarge: true,
      blocksSlot: ScreenSlot.midLeft,
    ),

    // Animales
    'leon': BackgroundItemInfo(emoji: '🦁', name: 'León'),
    'oso': BackgroundItemInfo(emoji: '🐻', name: 'Osito'),
    'perrito': BackgroundItemInfo(emoji: '🐶', name: 'Perrito'),
    'gatito': BackgroundItemInfo(emoji: '🐱', name: 'Gatito'),
    'conejito': BackgroundItemInfo(emoji: '🐰', name: 'Conejito'),
    'panda': BackgroundItemInfo(emoji: '🐼', name: 'Panda'),
    'gran_jirafa': BackgroundItemInfo(
      emoji: '🦒',
      name: 'Gran Jirafa (Alta)',
      isLarge: true,
      blocksSlot: ScreenSlot.bottomLeft,
    ),

    // Cohetes y Espacio
    'planeta': BackgroundItemInfo(emoji: '🪐', name: 'Planeta Saturno'),
    'ovni': BackgroundItemInfo(emoji: '🛸', name: 'Platillo Volador'),
    'astronauta': BackgroundItemInfo(emoji: '👨‍🚀', name: 'Astronauta'),
    'estrella': BackgroundItemInfo(emoji: '⭐', name: 'Estrella'),
    'gran_cohete': BackgroundItemInfo(
      emoji: '🚀',
      name: 'Gran Cohete Apolo (Grande)',
      isLarge: true,
      blocksSlot: ScreenSlot.midRight,
    ),

    // Estrellas y Cielo
    'nube': BackgroundItemInfo(emoji: '☁️', name: 'Nube Algodonosa'),
    'sol': BackgroundItemInfo(emoji: '☀️', name: 'Sol Alegre'),
    'arcoiris': BackgroundItemInfo(
      emoji: '🌈',
      name: 'Gran Arcoíris (Ancho)',
      isLarge: true,
      blocksSlot: ScreenSlot.topRight,
    ),

    // Vehículos
    'auto': BackgroundItemInfo(emoji: '🚗', name: 'Auto Veloz'),
    'avion': BackgroundItemInfo(emoji: '✈️', name: 'Avión de Pasajeros'),
    'barco': BackgroundItemInfo(emoji: '⛵', name: 'Barquito Velero'),
    'tren': BackgroundItemInfo(emoji: '🚂', name: 'Trencito a Vapor'),
  };
}

class BackgroundSettings {
  final BackgroundColorTheme colorTheme;
  final BackgroundDrawingTheme drawingTheme;
  final Map<ScreenSlot, String> slotAssignments;

  const BackgroundSettings({
    this.colorTheme = BackgroundColorTheme.original,
    this.drawingTheme = BackgroundDrawingTheme.estrellas,
    this.slotAssignments = const {},
  });

  BackgroundSettings copyWith({
    BackgroundColorTheme? colorTheme,
    BackgroundDrawingTheme? drawingTheme,
    Map<ScreenSlot, String>? slotAssignments,
  }) {
    return BackgroundSettings(
      colorTheme: colorTheme ?? this.colorTheme,
      drawingTheme: drawingTheme ?? this.drawingTheme,
      slotAssignments: slotAssignments ?? this.slotAssignments,
    );
  }

  /// Retorna los dibujos activos por slot garantizando que ninguno se pise
  Map<ScreenSlot, String> getEffectiveDrawings() {
    if (drawingTheme == BackgroundDrawingTheme.ninguno) {
      return {};
    }

    if (drawingTheme == BackgroundDrawingTheme.personalizado) {
      // Filtrar colisiones en modo personalizado
      final result = <ScreenSlot, String>{};
      final blockedSlots = <ScreenSlot>{};

      for (final slot in ScreenSlot.values) {
        final itemId = slotAssignments[slot];
        if (itemId == null || itemId.isEmpty) continue;
        if (blockedSlots.contains(slot)) continue; // Si este slot está pisado por otro, no se dibuja

        final item = BackgroundCatalog.items[itemId];
        if (item != null) {
          result[slot] = item.emoji;
          if (item.isLarge && item.blocksSlot != null) {
            blockedSlots.add(item.blocksSlot!);
          }
        }
      }
      return result;
    }

    // Temas predefinidos diseñados con lugares fijos sin solapamientos
    switch (drawingTheme) {
      case BackgroundDrawingTheme.princesas:
        return {
          ScreenSlot.topLeft: '👑',
          ScreenSlot.topRight: '🪄',
          ScreenSlot.midLeft: '🏰',
          ScreenSlot.midRight: '💎',
          ScreenSlot.bottomLeft: '👸',
          ScreenSlot.bottomRight: '🌸',
        };
      case BackgroundDrawingTheme.animales:
        return {
          ScreenSlot.topLeft: '🦁',
          ScreenSlot.topRight: '🐼',
          ScreenSlot.midLeft: '🐻',
          ScreenSlot.midRight: '🐰',
          ScreenSlot.bottomLeft: '🐶',
          ScreenSlot.bottomRight: '🐱',
        };
      case BackgroundDrawingTheme.cohetes:
        return {
          ScreenSlot.topLeft: '🪐',
          ScreenSlot.topRight: '🚀',
          ScreenSlot.midLeft: '🛸',
          ScreenSlot.midRight: '⭐',
          ScreenSlot.bottomLeft: '👨‍🚀',
          ScreenSlot.bottomRight: '✨',
        };
      case BackgroundDrawingTheme.estrellas:
        return {
          ScreenSlot.topLeft: '⭐',
          ScreenSlot.topRight: '☁️',
          ScreenSlot.midLeft: '✨',
          ScreenSlot.midRight: '☀️',
          ScreenSlot.bottomLeft: '🎈',
          ScreenSlot.bottomRight: '🌟',
        };
      case BackgroundDrawingTheme.vehiculos:
        return {
          ScreenSlot.topLeft: '✈️',
          ScreenSlot.topRight: '🚀',
          ScreenSlot.midLeft: '🚗',
          ScreenSlot.midRight: '🚂',
          ScreenSlot.bottomLeft: '⛵',
          ScreenSlot.bottomRight: '🚁',
        };
      case BackgroundDrawingTheme.personalizado:
      case BackgroundDrawingTheme.ninguno:
        return {};
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'colorTheme': colorTheme.id,
      'drawingTheme': drawingTheme.id,
      'slotAssignments': slotAssignments.map(
        (key, value) => MapEntry(key.name, value),
      ),
    };
  }

  factory BackgroundSettings.fromMap(Map<String, dynamic> map) {
    final colorTheme = BackgroundColorTheme.fromId(map['colorTheme'] as String? ?? 'original');
    final drawingTheme = BackgroundDrawingTheme.fromId(map['drawingTheme'] as String? ?? 'estrellas');

    final rawSlots = map['slotAssignments'] as Map<String, dynamic>? ?? {};
    final slotMap = <ScreenSlot, String>{};
    for (final entry in rawSlots.entries) {
      final slot = ScreenSlot.values.cast<ScreenSlot?>().firstWhere(
            (e) => e?.name == entry.key,
            orElse: () => null,
          );
      if (slot != null && entry.value is String) {
        slotMap[slot] = entry.value as String;
      }
    }

    return BackgroundSettings(
      colorTheme: colorTheme,
      drawingTheme: drawingTheme,
      slotAssignments: slotMap,
    );
  }

  String toJson() => json.encode(toMap());

  factory BackgroundSettings.fromJson(String source) =>
      BackgroundSettings.fromMap(json.decode(source) as Map<String, dynamic>);
}
