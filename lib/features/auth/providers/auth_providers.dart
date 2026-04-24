import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/role.dart';
import '../../../core/providers/firebase_providers.dart';
import '../data/auth_repository.dart';

part 'auth_providers.g.dart';

/// Instancia única del AuthRepository.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

/// Estado de autenticación actual. Emite `null` al cerrar sesión.
@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// Rol del usuario autenticado (`patient` o `professional`).
@riverpod
Future<UserRole?> currentUserRole(Ref ref) async {
  final auth = await ref.watch(authStateProvider.future);
  if (auth == null) return null;
  return ref.watch(authRepositoryProvider).fetchRoleOf(auth.uid);
}

/// Controller para acciones de auth (signup, signin, signout).
///
/// `keepAlive: true` evita que el controller se disponga cuando la pantalla
/// que lo está escuchando se desmonta durante un redirect del router.
/// Sin esto, Riverpod lanza "Bad state: Future already completed" porque
/// intenta completar el Future después de que el provider fue disposed.
///
/// Además, se usa un flag `_disposed` (registrado con `ref.onDispose`) para
/// evitar asignar `state` si — pese al keepAlive — el provider fuera invalidado
/// manualmente por algún motivo (por ejemplo, `ref.invalidate` en pruebas).
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  bool _disposed = false;

  @override
  FutureOr<void> build() {
    ref.onDispose(() {
      _disposed = true;
    });
    // Estado inicial: idle.
  }

  /// Asigna `newState` a `state` sólo si el provider sigue vivo.
  void _safeSetState(AsyncValue<void> newState) {
    if (_disposed) return;
    state = newState;
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    _safeSetState(const AsyncLoading());
    final result = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: email,
            password: password,
            fullName: fullName,
            role: role,
          );
    });
    _safeSetState(result);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _safeSetState(const AsyncLoading());
    final result = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: email,
            password: password,
          );
    });
    _safeSetState(result);
  }

  Future<void> signInWithGoogle({required UserRole role}) async {
    _safeSetState(const AsyncLoading());
    final result = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signInWithGoogle(role: role);
    });
    _safeSetState(result);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _safeSetState(const AsyncLoading());
    final result = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
    });
    _safeSetState(result);
  }

  Future<void> signOut() async {
    _safeSetState(const AsyncLoading());
    final result = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
    });
    _safeSetState(result);
  }
}