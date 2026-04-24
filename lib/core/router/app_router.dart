import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/shell/patient_placeholders.dart';
import '../../features/shell/patient_shell.dart';
import '../../features/shell/professional_placeholders.dart';
import '../../features/shell/professional_shell.dart';
import '../constants/role.dart';

part 'app_router.g.dart';

/// Convierte el stream de autenticación en un Listenable para go_router.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    refreshListenable: _GoRouterRefreshStream(authRepo.authStateChanges),

    /// Redirects:
    /// - Sin sesión + ruta protegida → /login
    /// - Con sesión + /login o /forgot-password → redirigir según rol
    /// - Si hay sesión pero el documento de Firestore aún no existe, mandamos
    ///   al usuario a /login (esto no debería pasar tras signup, pero es un fallback).
    redirect: (context, state) async {
      final loc = state.matchedLocation;
      final isLoggedIn = authRepo.currentUser != null;
      final isAuthRoute = loc == '/login' || loc == '/forgot-password';

      // Sin sesión → forzar login.
      if (!isLoggedIn) {
        return isAuthRoute ? null : '/login';
      }

      // Con sesión en una ruta de auth → mandar al home según rol.
      if (isAuthRoute) {
        final role = await authRepo.fetchRoleOf(authRepo.currentUser!.uid);
        if (role == UserRole.professional) return '/pro/home';
        return '/home';
      }

      // Con sesión en una ruta de paciente que debería ser profesional o viceversa.
      // Esto evita que un profesional vea el home de paciente por accidente.
      final isPatientRoute = loc.startsWith('/home') ||
          loc.startsWith('/search') ||
          loc.startsWith('/bookings') ||
          loc.startsWith('/history') ||
          loc.startsWith('/profile');
      final isProRoute = loc.startsWith('/pro');

      if (isPatientRoute || isProRoute) {
        final role = await authRepo.fetchRoleOf(authRepo.currentUser!.uid);
        if (role == UserRole.professional && isPatientRoute) return '/pro/home';
        if (role == UserRole.patient && isProRoute) return '/home';
      }

      return null;
    },

    routes: [
      // --- Rutas públicas de auth ---
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // --- Zona PACIENTE (con bottom nav) ---
      ShellRoute(
        builder: (context, state, child) => PatientShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: PatientHomePlaceholder()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: PatientSearchPlaceholder()),
          ),
          GoRoute(
            path: '/bookings',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: PatientBookingsPlaceholder()),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: PatientHistoryPlaceholder()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: PatientProfilePlaceholder()),
          ),
        ],
      ),

      // --- Zona PROFESIONAL (con bottom nav) ---
      ShellRoute(
        builder: (context, state, child) => ProfessionalShell(child: child),
        routes: [
          GoRoute(
            path: '/pro/home',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: ProfessionalHomePlaceholder()),
          ),
          GoRoute(
            path: '/pro/requests',
            pageBuilder: (_, __) => const NoTransitionPage(
                child: ProfessionalRequestsPlaceholder()),
          ),
          GoRoute(
            path: '/pro/availability',
            pageBuilder: (_, __) => const NoTransitionPage(
                child: ProfessionalAvailabilityPlaceholder()),
          ),
          GoRoute(
            path: '/pro/services',
            pageBuilder: (_, __) => const NoTransitionPage(
                child: ProfessionalServicesPlaceholder()),
          ),
          GoRoute(
            path: '/pro/profile',
            pageBuilder: (_, __) => const NoTransitionPage(
                child: ProfessionalProfilePlaceholder()),
          ),
        ],
      ),
    ],
  );
}
