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
/// Se usa para decidir la ruta inicial del router.
@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// Rol del usuario autenticado (`patient` o `professional`).
///
/// Si hay sesión pero no existe documento en ninguna colección, devuelve null
/// (esto puede pasar si el documento se perdió o si estamos a mitad del flujo
/// de registro; el router debería redirigir a selección de rol en ese caso).
@riverpod
Future<UserRole?> currentUserRole(Ref ref) async {
  final auth = await ref.watch(authStateProvider.future);
  if (auth == null) return null;
  return ref.watch(authRepositoryProvider).fetchRoleOf(auth.uid);
}

/// Controller para acciones de auth (signup, signin, signout).
/// Expone `AsyncValue<void>` para que la UI pueda mostrar loading/error.
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Estado inicial: idle.
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: email,
            password: password,
            fullName: fullName,
            role: role,
          );
    });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: email,
            password: password,
          );
    });
  }

  Future<void> signInWithGoogle({required UserRole role}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signInWithGoogle(role: role);
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
    });
  }
}
