import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/firestore_collections.dart';
import '../../core/providers/firebase_providers.dart';
import '../models/service.dart';
import 'base_repository.dart';

part 'services_repository.g.dart';

class ServicesRepository extends BaseFirestoreRepository<Service> {
  ServicesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.services);

  @override
  Service fromJson(Map<String, dynamic> json) => Service.fromJson(json);

  @override
  Map<String, dynamic> toJson(Service model) => model.toJson();

  /// Servicios activos de un profesional.
  Stream<List<Service>> watchByProfessional(String professionalId) {
    return collection
        .where('professional_id', isEqualTo: professionalId)
        .where('is_active', isEqualTo: true)
        .snapshots()
        .map(mapQuery);
  }

  /// Servicios activos por categoría.
  Stream<List<Service>> watchByCategory(String category, {int limit = 50}) {
    return collection
        .where('category', isEqualTo: category)
        .where('is_active', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map(mapQuery);
  }
}

@Riverpod(keepAlive: true)
ServicesRepository servicesRepository(Ref ref) =>
    ServicesRepository(ref.watch(firebaseFirestoreProvider));
