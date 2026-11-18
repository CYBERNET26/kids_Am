import 'package:kids_am/features/video_library/domain/models/video_item.dart';

/// ============================================================================
/// ARCHIVO DE VIDEOS EDUCATIVOS PREDETERMINADOS (POR DEFAULT)
/// ============================================================================
/// Aquí puedes agregar, editar o quitar todos los videos que vendrán de forma
/// fija en la aplicación.
///
/// Puedes colocar:
/// - Enlaces de YouTube:
///     - 'https://www.youtube.com/watch?v=...'
///     - 'https://youtu.be/...'
/// - Enlaces directos a archivos de video (MP4, etc.)
///
/// Parámetros de cada video:
/// - id: Identificador único (ej: 'video_1', 'video_2', etc.)
/// - title: Nombre del video que verá el niño
/// - description: Pequeña descripción o tema educativo
/// - urlOrAssetPath: El enlace de YouTube o URL directa
/// - category: 'Matemáticas', 'Ajedrez', 'Ciencias', 'Geometría', 'Música', etc.
/// - rewardStars: Cantidad de estrellas que gana el niño por verlo completo (ej: 3, 4, 5)
/// ============================================================================

final List<VideoItem> defaultEducationalVideos = [
  // --- VIDEO 1 ---
  const VideoItem(
    id: 'vid_default_01',
    title: 'Aprende los Números del 1 al 10 🎵',
    description: 'Canción didáctica y alegre para contar con animalitos',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=pSqkWk_Q_i4',
    sourceType: VideoSourceType.youtube,
    category: 'Matemáticas',
    rewardStars: 3,
  ),

  // --- VIDEO 2 ---
  const VideoItem(
    id: 'vid_default_02',
    title: 'Las Figuras Geométricas Divertidas 🔺🔵',
    description: 'Círculo, cuadrado, triángulo y rectángulo para niños',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=65wZuz-8u-k',
    sourceType: VideoSourceType.youtube,
    category: 'Geometría',
    rewardStars: 3,
  ),

  // --- VIDEO 3 ---
  const VideoItem(
    id: 'vid_default_03',
    title: 'Ajedrez para Niños: ¿Cómo se mueve la Torre y el Caballo? 🏰',
    description: 'Cuento interactivo para aprender las piezas de ajedrez',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=kYJv8Z1kZ50',
    sourceType: VideoSourceType.youtube,
    category: 'Ajedrez',
    rewardStars: 4,
  ),

  // --- VIDEO 4 ---
  const VideoItem(
    id: 'vid_default_04',
    title: 'Ajedrez para Niños: El Rey y la Dama 👑',
    description: 'Aprende los secretos y movimientos del Rey y la Reina',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=d_Z89M5L1n8',
    sourceType: VideoSourceType.youtube,
    category: 'Ajedrez',
    rewardStars: 4,
  ),

  // --- VIDEO 5 ---
  const VideoItem(
    id: 'vid_default_05',
    title: 'Aprende a Sumar de Manera Fácil y Divertida ➕',
    description: 'Explicación sencilla de sumas para niños de primaria',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=o0d428P3QvQ',
    sourceType: VideoSourceType.youtube,
    category: 'Matemáticas',
    rewardStars: 3,
  ),

  // --- VIDEO 6 ---
  const VideoItem(
    id: 'vid_default_06',
    title: 'Aprende a Restar con Manzanas y Juguetes ➖',
    description: 'Resta fácil y didáctica con ejemplos visuales',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=42vjqtleG9E',
    sourceType: VideoSourceType.youtube,
    category: 'Matemáticas',
    rewardStars: 3,
  ),

  // --- VIDEO 7 ---
  const VideoItem(
    id: 'vid_default_07',
    title: 'La Canción de la Tabla del 2 y del 3 ✖️',
    description: 'Música alegre para memorizar las primeras multiplicaciones',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=ecSXX971eL0',
    sourceType: VideoSourceType.youtube,
    category: 'Matemáticas',
    rewardStars: 5,
  ),

  // --- VIDEO 8 ---
  const VideoItem(
    id: 'vid_default_08',
    title: '¿Qué es la Multiplicación? Para Niños de 7 a 9 años 🧠',
    description: 'Entiende cómo multiplicar sumando grupos iguales',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=YFtEaVw5k1A',
    sourceType: VideoSourceType.youtube,
    category: 'Matemáticas',
    rewardStars: 4,
  ),

  // --- VIDEO 9 ---
  const VideoItem(
    id: 'vid_default_09',
    title: 'Aprende a Dividir: Repartir entre Amigos ➗',
    description: 'Explicación clara de la división exacta para niños',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=iA0fP4tLg7M',
    sourceType: VideoSourceType.youtube,
    category: 'Matemáticas',
    rewardStars: 5,
  ),

  // --- VIDEO 10 ---
  const VideoItem(
    id: 'vid_default_10',
    title: 'El Sistema Solar y los Planetas para Niños 🪐🚀',
    description: 'Viaje espacial por el sol, la luna y los 8 planetas',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=ZykXgSqet6A',
    sourceType: VideoSourceType.youtube,
    category: 'Ciencias',
    rewardStars: 4,
  ),

  // --- VIDEO 11 ---
  const VideoItem(
    id: 'vid_default_11',
    title: 'Los Animales Vertebrados e Invertebrados 🦁🐟',
    description: 'Descubre los mamíferos, aves, peces y reptiles',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=uQO5FF5eX9g',
    sourceType: VideoSourceType.youtube,
    category: 'Ciencias',
    rewardStars: 3,
  ),

  // --- VIDEO 12 ---
  const VideoItem(
    id: 'vid_default_12',
    title: 'Cuento de Ajedrez: El Peón Valiente ♟️',
    description: 'Historia motivacional sobre cómo el peón puede convertirse en dama',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=1xWq7Pz0Qv0',
    sourceType: VideoSourceType.youtube,
    category: 'Ajedrez',
    rewardStars: 4,
  ),

  // --------------------------------------------------------------------------
  // PUEDES SEGUIR AGREGANDO MÁS VIDEOS AQUÍ ABAJO (COPIA Y PEGA EL FORMATO):
  // --------------------------------------------------------------------------
  // const VideoItem(
  //   id: 'vid_default_13',
  //   title: 'Título de tu video',
  //   description: 'Descripción breve',
  //   urlOrAssetPath: 'https://www.youtube.com/watch?v=TU_ENLACE_AQUI',
  //   sourceType: VideoSourceType.youtube,
  //   category: 'Matemáticas', // o 'Ajedrez', 'Ciencias', etc.
  //   rewardStars: 3,
  // ),
];
