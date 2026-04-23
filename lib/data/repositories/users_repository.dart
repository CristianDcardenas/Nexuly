import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/firestore_collections.dart';
import '../../core/providers/firebase_providers.dart';
import '../models/app_user.dart';
import 'base_repository.dart';

part 'users_repository.g.dart';

class UsersRepository extends BaseFirestoreRepository<AppUser> {
  UsersRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.users);

  @override
  AppUser fromJson(Map<String, dynamic> json) => AppUser.fromJson(json);

  @override
  Map<String, dynamic> toJson(AppUser model) => model.toJson();

  /// Stream del perfil del usuario actual.
  Stream<AppUser?> watch(String uid) => watchById(uid);

  /// Crea el documento de un usuario recién registrado.
  /// Usa `merge: true` para no pisar campos que haya puesto una Cloud Function.
  Future<void> createOnSignup(AppUser user) => set(user.uid, user);

  /// Soft delete lógico (is_active = false, is_anonymous = true).
  Future<void> softDelete(String uid) => update(uid, {
        'is_active': false,
        'is_anonymous': true,
        'updated_at': FieldValue.serverTimestamp(),
      });

  // ---------- medical_profile ----------

  DocumentReference<Map<String, dynamic>> _medicalDoc(String uid) => collection
      .doc(uid)
      .collection(FirestoreCollections.medicalProfile)
      .doc(FirestoreCollections.medicalProfileDocId);

  Future<MedicalProfile?> getMedicalProfile(String uid) async {
    final doc = await _medicalDoc(uid).get();
    if (!doc.exists) return null;
    return MedicalProfile.fromJson(doc.data()!);
  }

  Future<void> setMedicalProfile(String uid, MedicalProfile profile) =>
      _medicalDoc(uid).set(profile.toJson(), SetOptions(merge: true));

  // ---------- blocked_professionals ----------

  CollectionReference<Map<String, dynamic>> _blockedCol(String uid) =>
      collection
          .doc(uid)
          .collection(FirestoreCollections.blockedProfessionals);

  Future<void> blockProfessional(
    String uid,
    BlockedProfessional blocked,
  ) =>
      _blockedCol(uid).doc(blocked.professionalId).set(blocked.toJson());

  Future<void> unblockProfessional(String uid, String professionalId) =>
      _blockedCol(uid).doc(professionalId).delete();

  Stream<List<BlockedProfessional>> watchBlocked(String uid) {
    return _blockedCol(uid).snapshots().map(
          (snap) => snap.docs
              .map((d) => BlockedProfessional.fromJson(d.data()))
              .toList(),
        );
  }
}

@Riverpod(keepAlive: true)
UsersRepository usersRepository(Ref ref) =>
    UsersRepository(ref.watch(firebaseFirestoreProvider));

/// Stream del perfil del usuario autenticado actual.
@riverpod
Stream<AppUser?> currentUserProfile(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(usersRepositoryProvider).watch(uid);
}
