import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/notes/presentation/pages/home_page.dart';
import '../../features/notes/presentation/pages/add_note_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/notes/data/models/note_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final currentPath = state.uri.toString();
      final isGoingToAuth = currentPath == '/login' || currentPath == '/register';
      final isGoingToSplash = currentPath == '/splash';

      // If not logged in and not going to auth pages, redirect to login
      if (!isLoggedIn && !isGoingToAuth && !isGoingToSplash) {
        return '/login';
      }

      // If logged in and going to auth pages, redirect to home
      if (isLoggedIn && isGoingToAuth) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/add-note',
        builder: (context, state) {
          final note = state.extra as NoteModel?;
          return AddNotePage(note: note);
        },
      ),
    ],
  );
});