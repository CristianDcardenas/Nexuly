import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/constants/role.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/professional.dart';

/// Repositorio de autenticación.
///
/// Encapsula toda la interacción con Firebase Auth, Google Sign-In y la
/// creación del documento de usuario/profesional en Firestore al registrarse.
///
/// NO gestiona estado — eso lo hacen los providers de Riverpod.
class AuthRepository {
  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        // En web NO inicializamos GoogleSignIn (requiere clientId en un meta
        // tag y además usamos signInWithPopup de Firebase Auth directamente).
        // En mobile/desktop, sí lo usamos.
        _googleSignIn = kIsWeb ? null : (googleSignIn ?? GoogleSignIn());

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn? _googleSignIn;

  // ---------------------------------------------------------------------------
  // Estado de sesión
  // ---------------------------------------------------------------------------

  /// Stream del estado de autenticación. Emite `null` al cerrar sesión.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actualmente autenticado (síncrono, `null` si no hay sesión).
  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // Registro con email / password
  // ---------------------------------------------------------------------------

  /// Crea un usuario nuevo con email y password, y su documento en Firestore
  /// en la colección correspondiente según el rol.
  ///
  /// Devuelve el `User` de Firebase Auth ya autenticado.
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AuthFailure('No se pudo crear la cuenta');
      }

      // Actualizamos el displayName en Firebase Auth para tenerlo disponible
      // en todos lados sin tener que leer Firestore.
      await user.updateDisplayName(fullName.trim());

      // Creamos el documento en Firestore según el rol elegido.
      await _createUserDocument(
        user: user,
        fullName: fullName.trim(),
        role: role,
        authProvider: 'email',
      );

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthFailure('Error al registrarse', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Login con email / password
  // ---------------------------------------------------------------------------

  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AuthFailure('No se pudo iniciar sesión');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthFailure('Error al iniciar sesión', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  /// Inicia sesión con Google. Si es la primera vez, crea el documento en
  /// Firestore con el rol indicado. Si el usuario ya existía, respeta su
  /// documento actual (no lo pisa).
  Future<User> signInWithGoogle({required UserRole role}) async {
    try {
      final UserCredential cred;

      if (kIsWeb) {
        // En web, Firebase Auth maneja Google Sign-In vía popup/redirect.
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        cred = await _auth.signInWithPopup(provider);
      } else {
        // En mobile/desktop, usamos el SDK de google_sign_in.
        final googleUser = await _googleSignIn!.signIn();
        if (googleUser == null) {
          throw const AuthFailure('Cancelado por el usuario');
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        cred = await _auth.signInWithCredential(credential);
      }

      final user = cred.user;
      if (user == null) {
        throw const AuthFailure('No se pudo iniciar sesión con Google');
      }

      // Si es un usuario nuevo, creamos su documento en Firestore.
      final isNewUser = cred.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        await _createUserDocument(
          user: user,
          fullName: user.displayName ?? user.email?.split('@').first ?? '',
          role: role,
          authProvider: 'google',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      if (e is NexulyFailure) rethrow;
      throw AuthFailure('Error al iniciar con Google', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Recuperación de contraseña
  // ---------------------------------------------------------------------------

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AuthFailure('Error al enviar el correo', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    try {
      // Cerrar sesión en ambos lados para evitar "sticky" sessions.
      await Future.wait([
        _auth.signOut(),
        if (_googleSignIn != null) _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthFailure('Error al cerrar sesión', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Verificación del rol actual (lee Firestore)
  // ---------------------------------------------------------------------------

  /// Determina el rol del usuario autenticado leyendo los documentos en
  /// Firestore. Útil para el router al iniciar la app.
  ///
  /// Devuelve `null` si no existe en ninguna de las dos colecciones.
  Future<UserRole?> fetchRoleOf(String uid) async {
    // Leemos ambos en paralelo.
    final results = await Future.wait([
      _firestore.collection(FirestoreCollections.users).doc(uid).get(),
      _firestore.collection(FirestoreCollections.professionals).doc(uid).get(),
    ]);

    if (results[0].exists) return UserRole.patient;
    if (results[1].exists) return UserRole.professional;
    return null;
  }

  // ---------------------------------------------------------------------------
  // Helpers privados
  // ---------------------------------------------------------------------------

  /// Crea el documento en `users` o `professionals` según el rol.
  /// Idempotente: usa `set` con merge para no duplicar si se llama dos veces.
  Future<void> _createUserDocument({
    required User user,
    required String fullName,
    required UserRole role,
    required String authProvider,
  }) async {
    final now = DateTime.now();

    if (role == UserRole.patient) {
      final appUser = AppUser(
        uid: user.uid,
        fullName: fullName,
        email: user.email ?? '',
        phone: user.phoneNumber,
        photoUrl: user.photoURL,
        authProviders: [authProvider],
        verificationLevel: 'basic',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set(appUser.toJson(), SetOptions(merge: true));
    } else {
      final professional = Professional(
        uid: user.uid,
        fullName: fullName,
        email: user.email ?? '',
        phone: user.phoneNumber ?? '',
        photoUrl: user.photoURL,
        validationStatus: 'pending',
        isActive: true,
        isAvailable: false,
        // Ubicación por defecto (0,0). El profesional la define en onboarding.
        location: const GeoPoint(0, 0),
        createdAt: now,
        updatedAt: now,
      );
      await _firestore
          .collection(FirestoreCollections.professionals)
          .doc(user.uid)
          .set(professional.toJson(), SetOptions(merge: true));
    }
  }

  /// Mapea errores de Firebase Auth a mensajes claros en español.
  AuthFailure _mapAuthException(FirebaseAuthException e) {
    final message = switch (e.code) {
      'user-not-found' => 'No existe una cuenta con ese correo',
      'wrong-password' || 'invalid-credential' =>
        'Correo o contraseña incorrectos',
      'invalid-email' => 'El correo no es válido',
      'user-disabled' => 'Esta cuenta fue deshabilitada',
      'email-already-in-use' => 'Ya existe una cuenta con ese correo',
      'weak-password' => 'La contraseña es muy débil (mínimo 6 caracteres)',
      'operation-not-allowed' =>
        'Este método de autenticación no está habilitado',
      'network-request-failed' => 'Sin conexión a internet',
      'too-many-requests' =>
        'Demasiados intentos. Intenta de nuevo más tarde',
      'account-exists-with-different-credential' =>
        'Ya existe una cuenta con ese correo usando otro método de inicio',
      'popup-closed-by-user' ||
      'cancelled-popup-request' =>
        'Cancelado por el usuario',
      _ => e.message ?? 'Error de autenticación',
    };
    return AuthFailure(message, e);
  }
}