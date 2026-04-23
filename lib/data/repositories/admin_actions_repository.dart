import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/firestore_collections.dart';
import '../../core/providers/firebase_providers.dart';
import '../models/admin_action.dart';
import 'base_repository.dart';

part 'admin_actions_repository.g.dart';

/// Repositorio de `admin_actions`. Solo accesible por usuarios con custom
/// claim `role == 'admin'` (ver firestore.rules).
class AdminActionsRepository extends BaseFirestoreRepository<AdminAction> {
  AdminActionsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.adminActions);

  @override
  AdminAction fromJson(Map<String, dynamic> json) =>
      AdminAction.fromJson(json);

  @override
  Map<String, dynamic> toJson(AdminAction model) => model.toJson();

  /// Historial de acciones sobre un target específico.
  Stream<List<AdminAction>> watchByTarget(String targetId, {int limit = 50}) {
    return collection
        .where('target_id', isEqualTo: targetId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(mapQuery);
  }

  /// Historial general (panel admin).
  Stream<List<AdminAction>> watchRecent({int limit = 100}) {
    return collection
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(mapQuery);
  }
}

@Riverpod(keepAlive: true)
AdminActionsRepository adminActionsRepository(Ref ref) =>
    AdminActionsRepository(ref.watch(firebaseFirestoreProvider));
