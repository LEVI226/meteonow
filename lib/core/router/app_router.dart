import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/weather/presentation/home_screen.dart';
import '../../features/weather/presentation/search_screen.dart';
import 'go_router_refresh_stream.dart';

class _NavDestination {
  const _NavDestination(this.path, this.routeName, this.icon, this.selectedIcon, this.label);
  final String path;
  final String routeName;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _destinations = [
  _NavDestination('/', 'home', Icons.wb_cloudy_outlined, Icons.wb_cloudy, 'Home'),
  _NavDestination('/search', 'search', Icons.search_outlined, Icons.search, 'Search'),
  _NavDestination('/favorites', 'favorites', Icons.bookmark_border, Icons.bookmark, 'Favorites'),
  _NavDestination('/profile', 'profile', Icons.person_outline, Icons.person, 'Profile'),
];

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location) {
    final index = _destinations.indexWhere((d) => d.path == location);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => context.goNamed(_destinations[index].routeName),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
        ],
      ),
    );
  }
}

GoRouter buildRouter({required AuthRepository authRepository}) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    redirect: (context, state) {
      final loggedIn = authRepository.currentUser != null;
      final onAuthScreen = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (!loggedIn && !onAuthScreen) return '/login';
      if (loggedIn && onAuthScreen) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', name: 'register', builder: (context, state) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', name: 'home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/search', name: 'search', builder: (context, state) => const SearchScreen()),
          GoRoute(path: '/favorites', name: 'favorites', builder: (context, state) => const FavoritesScreen()),
          GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),
    ],
  );
}
