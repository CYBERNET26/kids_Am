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
    title: 'Necesidades, derechos y lucha de flamencos | Tuttle Twins en Español | T2E1',
    description: 'Cuando una excursión sale mal, los mellizos se preguntan si las necesidades son realmente derechos. Aprenden acerca de los derechos naturales de John Locke y luchan por sus vidas en una isla de feroces flamencos.',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=iY1r7U3jVFY&list=PLOe_XajSj1xiCOyhnf74R0ELDV0D0SWSn&index=3',
    sourceType: VideoSourceType.youtube,
    category: 'Educación Económica',
    rewardStars: 3,
  ),

  // --- VIDEO 2 ---
  const VideoItem(
    id: 'vid_default_02',
    title: 'No deseches el éxito | Tuttle Twins en Español | T2E2',
    description: 'Cuando los mellizos triunfan con un negocio de limpieza de botes de basura, Karinne les hace cuestionar si el éxito es egoísta. ¡Aprenden sobre el verdadero emprendimiento de Joyce Chen y los gruñones gruñodons de Gruñolandia!',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=zHRVP3o3we4&list=PLOe_XajSj1xiCOyhnf74R0ELDV0D0SWSn&index=1',
    sourceType: VideoSourceType.youtube,
    category: 'Educación Económica',
    rewardStars: 3,
  ),

  // --- VIDEO 3 ---
  const VideoItem(
    id: 'vid_default_03',
    title: 'Bitcoin y la Bestia | Tuttle Twins en Español | T2E3 ',
    description: '¡Sagrado Satoshi! Cuando los mellizos se ven obligados a elegir entre aceptar dólares y Bitcoin en una venta de garaje, viajan por el internet y un videojuego retro para aprender qué es lo que hace que el dinero sea bueno.',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=Y_1VUGEUT-c&list=PLOe_XajSj1xiCOyhnf74R0ELDV0D0SWSn&index=5',
    sourceType: VideoSourceType.youtube,
    category: 'Educación Económica',
    rewardStars: 3,
  ),

  // --- VIDEO 4 ---
  const VideoItem(
    id: 'vid_default_04',
    title: 'Piensa fuera del corral | Tuttle Twins en Español | T2E4',
    description: 'Después de que su equipo de softbol comienza a romper las reglas, los mellizos saltan a través de famosos cuadros, conocen a George Washington e intentan salvar una granja dividida de un lobo feroz y el peligroso tribalismo.',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=SqUJxWIRgWU&list=PLOe_XajSj1xiCOyhnf74R0ELDV0D0SWSn&index=9',
    sourceType: VideoSourceType.youtube,
    category: 'Educación Económica',
    rewardStars: 3,
  ),

  // --- VIDEO 5 ---
  const VideoItem(
    id: 'vid_default_05',
    title: 'Un T-Rex e ideas enredadas | Tuttle Twins en Español | T2E5 |',
    description: 'Después de que un T-rex destruye su casa del árbol, los mellizos luchan por salvar el reino agobiado de Rapunzel y descubren que las buenas ideas pueden provenir de personas imperfectas.',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=SiPLOceTvOs&list=PLOe_XajSj1xiCOyhnf74R0ELDV0D0SWSn&index=7',
    sourceType: VideoSourceType.youtube,
    category: 'Educación Económica',
    rewardStars: 3,
  ),

  // --- VIDEO 6 ---
  const VideoItem(
    id: 'vid_default_06',
    title: 'La incy wincy mentalidad de víctima | Tuttle Twins en Español | T2E6',
    description: 'Cuando los mellizos son injustamente eliminados de un show de talentos, la abuela los lleva a conocer a Frederick Douglass y a una pequeñísima araña para aprender cómo superar la mentalidad de víctima.',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=cHHefhoTuXs&list=PLOe_XajSj1xiCOyhnf74R0ELDV0D0SWSn&index=4',
    sourceType: VideoSourceType.youtube,
    category: 'Educación Económica',
    rewardStars: 3,
  ),

  // --- VIDEO 7 ---
  const VideoItem(
    id: 'vid_default_07',
    title: 'Criaturas del mar y planificación central | Tuttle Twins en Español | T2E7',
    description: 'En medio de las peculiaridades del programa escolar, la abuela presenta a los gemelos al economista Fredrick Hayek. Se desata el caos de la planificación central, pero una reina sirena sabe exactamente cómo ayudar a Ethan y Emily a solucionarlo.',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=o1yjkrx65-g&list=PLOe_XajSj1xiCOyhnf74R0ELDV0D0SWSn&index=2',
    sourceType: VideoSourceType.youtube,
    category: 'Educación Económica',
    rewardStars: 3,
  ),

  // --- VIDEO 8 ---
  const VideoItem(
    id: 'vid_default_08',
    title: 'Sustos con sucios subsidios | Tuttle Twins en Español | T2E8',
    description: 'Cuando el negocio de los mellizos se ve perjudicado por un subsidio, visitan a Ludwig Von Mises y aterrizan en un lugar espeluznante donde aprenden cuán desagradable puede llegar a ser el mercado',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=6BEDSpKZWiY&list=PLOe_XajSj1xiCOyhnf74R0ELDV0D0SWSn&index=12',
    sourceType: VideoSourceType.youtube,
    category: 'Educación Económica',
    rewardStars: 3,
  ),

  // --- VIDEO 9 ---
  const VideoItem(
    id: 'vid_default_09',
    title: 'Luchando con el socialismo | Tuttle Twins en Español | T2E9 ',
    description: '¡LUCHA! Después de una recaudación de fondos fallida para el club de niños, la banda se encuentra con William Bradford, los peregrinos y Karl Marx mientras luchan con el socialismo y sus consecuencias.',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=NTUHbVYnLjI&list=PLOe_XajSj1xiCOyhnf74R0ELDV0D0SWSn&index=10',
    sourceType: VideoSourceType.youtube,
    category: 'Educación Económica',
    rewardStars: 3,
  ),

  // --- VIDEO 10 ---
  const VideoItem(
    id: 'vid_default_10',
    title: 'La jungla de la educación | Tuttle Twins en Español | T2E10 ',
    description: 'Después de que Emily reprueba un examen, los mellizos se preguntan si la escuela es la mejor manera de aprender, lo que provoca que la abuela los lleve a un lugar familiar en el pasado, antes de pasar por la mente más famosa de la historia y luego un estruendo en la jungla.',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=Y1RIJKi-ZpI&list=PLOe_XajSj1xiCOyhnf74R0ELDV0D0SWSn&index=6',
    sourceType: VideoSourceType.youtube,
    category: 'Ciencias',
    rewardStars: 3,
  ),

  // --- VIDEO 11 ---
  const VideoItem(
    id: 'vid_default_11',
    title: 'Secuestradores y Capitalismo | Tuttle Twins en Español | T2E11',
    description: 'Invasores de otro mundo secuestran a Derek, lanzando a la abuela y a los mellizos en una peligrosa misión de rescate. En un planeta sombrío, los mellizos encuentran pistas misteriosas, cyborgs y dispositivos de espionaje mientras solucionan el misterio de por qué el capitalismo está fallando.',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=Hl6hZmzKDag&list=PLOe_XajSj1xiCOyhnf74R0ELDV0D0SWSn&index=11',
    sourceType: VideoSourceType.youtube,
    category: 'Educación Económica',
    rewardStars: 3,
  ),

  // --- VIDEO 12 ---
  const VideoItem(
    id: 'vid_default_12',
    title: 'Desastre de dinero | Tuttle Twins en Español | T2E12',
    description: 'Es la época de Navidad, y cuando los mellizos discuten sobre ahorrar dinero versus gastarlo, la abuela les presenta un juego de mesa que desata criaturas y caos en la casa de los Tuttle.',
    urlOrAssetPath: 'https://www.youtube.com/watch?v=TRd3NhuW6gM&list=PLOe_XajSj1xiCOyhnf74R0ELDV0D0SWSn&index=8',
    sourceType: VideoSourceType.youtube,
    category: 'Educación Económica',
    rewardStars: 3,
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
