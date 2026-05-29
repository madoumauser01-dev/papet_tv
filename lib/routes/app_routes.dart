import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/navigation/presentation/screens/shell_screen.dart';
import '../features/network_browser/presentation/screens/network_list_screen.dart';
import '../features/network_browser/presentation/screens/smb_browser_screen.dart';
import '../features/favorites/presentation/screens/favorites_screen.dart';
import '../features/local_browser/presentation/screens/local_browser_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/home/video_player_screen.dart';
import '../models/video_item.dart';

class AppRoutes {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/network',
    routes: [
      // Stateful Shell Route for the bottom tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Network Explorer
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/network',
                builder: (context, state) => const NetworkListScreen(),
              ),
              GoRoute(
                path: '/browser',
                builder: (context, state) => const SmbBrowserScreen(),
              ),
            ],
          ),
          // Branch 1: Folder Bookmarks (Favorites)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          // Branch 2: Local File Explorer
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/local',
                builder: (context, state) => const LocalBrowserScreen(),
              ),
            ],
          ),
          // Branch 3: Settings Screen
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Video Player Route outside of Bottom Navigation (Full Screen)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/player',
        builder: (context, state) {
          final video = state.extra as VideoItem;
          return VideoPlayerScreen(video: video);
        },
      ),
    ],
  );
}
