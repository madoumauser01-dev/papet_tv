import 'package:go_router/go_router.dart';
import '../features/home/video_player_screen.dart';
import '../features/network_browser/presentation/screens/network_list_screen.dart';
import '../features/network_browser/presentation/screens/smb_browser_screen.dart';
import '../models/video_item.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/network',
    routes: [
      GoRoute(
        path: '/network',
        builder: (context, state) => const NetworkListScreen(),
      ),
      GoRoute(
        path: '/browser',
        builder: (context, state) => const SmbBrowserScreen(),
      ),
      GoRoute(
        path: '/player',
        builder: (context, state) {
          final video = state.extra as VideoItem;
          return VideoPlayerScreen(video: video);
        },
      ),
    ],
  );
}
