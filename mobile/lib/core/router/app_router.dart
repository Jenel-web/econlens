import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import screens (to be created)
import '../../presentation/splash/splash_screen.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/home/notifications_screen.dart';
import '../../presentation/home/about_screen.dart';
import '../../presentation/article/article_detail_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../main.dart' show BackendCheckScreen;

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/article',
      builder: (context, state) {
        final news = state.extra as NewsItem;
        return ArticleDetailScreen(news: news);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    // Hidden developer route
    GoRoute(
      path: '/dev/backend-check',
      builder: (context, state) => const BackendCheckScreen(),
    ),
  ],
);
