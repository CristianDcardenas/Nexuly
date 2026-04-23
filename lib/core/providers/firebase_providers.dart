import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

/// Instancia global de FirebaseAuth.
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

/// Instancia global de Firestore.
@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

/// Instancia global de Firebase Storage.
@Riverpod(keepAlive: true)
FirebaseStorage firebaseStorage(Ref ref) => FirebaseStorage.instance;

/// Stream del estado de autenticación. Se escucha desde el router / splash
/// para saber si hay sesión activa.
@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) =>
    ref.watch(firebaseAuthProvider).authStateChanges();

/// UID del usuario autenticado (null si no hay sesión).
@riverpod
String? currentUserId(Ref ref) {
  final auth = ref.watch(authStateChangesProvider);
  return auth.valueOrNull?.uid;
}
