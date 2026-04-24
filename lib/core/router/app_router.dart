import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/booking/presentation/booking_confirmation_screen.dart';
import '../../features/booking/presentation/booking_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/professional_detail/presentation/professional_detail_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/shell/patient_placeholders.dart';
import '../../features/shell/patient_shell.dart';
import '../../features/shell/professional_placeholders.dart';
import '../../features/shell/professional_shell.dart';
import '../../features/user_profile/presentation/user_profile_screen.dart';
import '../constants/role.dart';

part 'app_router.g.dart';

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
    redirect: (context, state) async {
      final loc = state.matchedLocation;
      final isLoggedIn = authRepo.currentUser != null;
      final isAuthRoute = loc == '/login' || loc == '/forgot-password';

      if (!isLoggedIn) {
        return isAuthRoute ? null : '/login';
      }

      if (isAuthRoute) {
        final role = await authRepo.fetchRoleOf(authRepo.currentUser!.uid);
        if (role == UserRole.professional) return '/pro/home';
        return '/home';
      }

      final isPatientRoute = loc == '/home' ||
          loc.startsWith('/home/') ||
          loc == '/search' ||
          loc.startsWith('/search/') ||
          loc == '/bookings' ||
          loc.startsWith('/bookings/') ||
          loc == '/history' ||
          loc.startsWith('/history/') ||
          loc == '/profile' ||
          loc.startsWith('/profile/') ||
          loc.startsWith('/professional/') ||
          loc.startsWith('/booking/');
      // IMPORTANTE: usamos `/pro/` con slash para no capturar `/professional/:id`
      // (esa ruta es de detalle accesible para pacientes).
      final isProRoute = loc == '/pro' || loc.startsWith('/pro/');

      if (isPatientRoute || isProRoute) {
        final role = await authRepo.fetchRoleOf(authRepo.currentUser!.uid);
        if (role == UserRole.professional && isPatientRoute) return '/pro/home';
        if (role == UserRole.patient && isProRoute) return '/home';
      }

      return null;
    },

    routes: [
      // --- Auth pública ---
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // --- Detalle de profesional (fullscreen, fuera del shell) ---
      GoRoute(
        path: '/professional/:id',
        builder: (context, state) => ProfessionalDetailScreen(
          professionalId: state.pathParameters['id']!,
        ),
      ),

      // --- Flujo de reserva (fullscreen, fuera del shell) ---
      GoRoute(
        path: '/booking/:id',
        builder: (context, state) => BookingScreen(
          professionalId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/booking-confirmation/:id',
        builder: (context, state) => BookingConfirmationScreen(
          requestId: state.pathParameters['id']!,
        ),
      ),

      // --- Zona PACIENTE (con bottom nav) ---
      ShellRoute(
        builder: (context, state, child) => PatientShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (_, state) {
              final category = state.uri.queryParameters['category'];
              return NoTransitionPage(
                child: SearchScreen(initialCategory: category),
              );
            },
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
                const NoTransitionPage(child: UserProfileScreen()),
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
