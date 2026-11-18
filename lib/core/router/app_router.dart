import 'package:go_router/go_router.dart';
import 'package:kids_am/features/home/presentation/screens/kids_home_screen.dart';
import 'package:kids_am/features/parent_zone/presentation/screens/parent_gate_screen.dart';
import 'package:kids_am/features/video_library/domain/models/video_item.dart';
import 'package:kids_am/features/video_library/presentation/screens/video_catalog_screen.dart';
import 'package:kids_am/features/video_library/presentation/screens/safe_video_player_screen.dart';
import 'package:kids_am/features/games/visual_math/presentation/screens/visual_math_screen.dart';
import 'package:kids_am/features/games/chess/presentation/screens/chess_game_screen.dart';
import 'package:kids_am/features/games/puzzle/presentation/screens/puzzle_game_screen.dart';
import 'package:kids_am/features/stories/domain/models/story_item.dart';
import 'package:kids_am/features/stories/presentation/screens/stories_catalog_screen.dart';
import 'package:kids_am/features/stories/presentation/screens/story_reader_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const KidsHomeScreen(),
    ),
    GoRoute(
      path: '/parent-gate',
      builder: (context, state) => const ParentGateScreen(),
    ),
    GoRoute(
      path: '/stories',
      builder: (context, state) => const StoriesCatalogScreen(),
      routes: [
        GoRoute(
          path: 'read',
          builder: (context, state) {
            final story = state.extra as StoryItem;
            return StoryReaderScreen(story: story);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/videos',
      builder: (context, state) => const VideoCatalogScreen(),
      routes: [
        GoRoute(
          path: 'play',
          builder: (context, state) {
            final video = state.extra as VideoItem;
            return SafeVideoPlayerScreen(video: video);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/games/math',
      builder: (context, state) => const VisualMathScreen(),
    ),
    GoRoute(
      path: '/games/chess',
      builder: (context, state) => const ChessGameScreen(),
    ),
    GoRoute(
      path: '/games/puzzle',
      builder: (context, state) => const PuzzleGameScreen(),
    ),
  ],
);

