import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/constants/role.dart';
import '../../../core/errors/failures.dart';

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
      try {
        await _createUserDocument(
          user: user,
          fullName: fullName.trim(),
          role: role,
          authProvider: 'email',
        );
      } catch (docError) {
        // Si la creación del documento falla, mostramos un error más claro
        // y no dejamos al usuario en un estado "huérfano" (auth sin doc).
        debugPrint(
          '⚠️ Error creando documento Firestore tras signUp: $docError',
        );
        rethrow;
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } on FirebaseException catch (e) {
      // Error escribiendo en Firestore (rules denegadas, etc).
      throw AuthFailure(
        'Cuenta creada pero no se pudo guardar tu perfil: ${e.code}. '
        'Intenta cerrar sesión y volver a iniciar.',
        e,
      );
    } catch (e) {
      if (e is NexulyFailure) rethrow;
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

  Future<User> signInWithGoogle({required UserRole role}) async {
    try {
      final UserCredential cred;

      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        cred = await _auth.signInWithPopup(provider);
      } else {
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

  Future<UserRole?> fetchRoleOf(String uid) async {
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
  ///
  /// IMPORTANTE: Usamos `FieldValue.serverTimestamp()` en `created_at` y
  /// `updated_at` porque las Security Rules exigen:
  ///   `request.resource.data.created_at == request.time`
  /// Es decir, el timestamp DEBE ser el del servidor. Si usáramos
  /// `DateTime.now()` del cliente, la rule siempre fallaría porque
  /// los dos tiempos nunca coinciden exactamente.
  ///
  /// También construimos el Map a mano en vez de usar `model.toJson()`
  /// para poder mezclar campos regulares con `FieldValue` (el `toJson`
  /// de Freezed devuelve un Map que no permite sentinels).
  Future<void> _createUserDocument({
    required User user,
    required String fullName,
    required UserRole role,
    required String authProvider,
  }) async {
    if (role == UserRole.patient) {
      final data = <String, dynamic>{
        'uid': user.uid,
        'full_name': fullName,
        'email': user.email ?? '',
        if (user.phoneNumber != null) 'phone': user.phoneNumber,
        if (user.photoURL != null) 'photo_url': user.photoURL,
        'auth_providers': [authProvider],
        'verification_level': 'basic',
        'is_active': true,
        'email_verified': user.emailVerified,
        'phone_verified': false,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set(data);
    } else {
      final data = <String, dynamic>{
        'uid': user.uid,
        'full_name': fullName,
        'email': user.email ?? '',
        'phone': user.phoneNumber ?? '',
        if (user.photoURL != null) 'photo_url': user.photoURL,
        'validation_status': 'pending',
        'rejection_count': 0,
        'is_active': true,
        'is_available': false,
        'do_not_disturb': false,
        'location': const GeoPoint(0, 0),
        'coverage_type': 'radius',
        'coverage_radius_km': 10.0,
        'coverage_zones': <String>[],
        'specialties': <String>[],
        'rating_avg': 0.0,
        'rating_count': 0,
        'response_time_avg_min': 0,
        'acceptance_rate': 0.0,
        'completion_rate': 0.0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection(FirestoreCollections.professionals)
          .doc(user.uid)
          .set(data);
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