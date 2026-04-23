import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/firestore_collections.dart';
import '../../core/providers/firebase_providers.dart';
import '../models/user_behavior.dart';
import 'base_repository.dart';

part 'user_behavior_repository.g.dart';

/// Repositorio de user_behavior. **Lectura únicamente desde el cliente.**
/// Cloud Functions es el único autorizado a escribir (ver firestore.rules).
class UserBehaviorRepository extends BaseFirestoreRepository<UserBehavior> {
  UserBehaviorRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.userBehavior);

  @override
  UserBehavior fromJson(Map<String, dynamic> json) =>
      UserBehavior.fromJson(json);

  @override
  Map<String, dynamic> toJson(UserBehavior model) => model.toJson();

  Stream<UserBehavior?> watch(String uid) => watchById(uid);
}

@Riverpod(keepAlive: true)
UserBehaviorRepository userBehaviorRepository(Ref ref) =>
    UserBehaviorRepository(ref.watch(firebaseFirestoreProvider));
