import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/firestore_collections.dart';
import '../../core/providers/firebase_providers.dart';
import '../models/professional.dart';
import 'base_repository.dart';

part 'professionals_repository.g.dart';

class ProfessionalsRepository extends BaseFirestoreRepository<Professional> {
  ProfessionalsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.professionals);

  @override
  Professional fromJson(Map<String, dynamic> json) =>
      Professional.fromJson(json);

  @override
  Map<String, dynamic> toJson(Professional model) => model.toJson();

  /// Profesionales aprobados, activos y disponibles.
  /// Requiere el índice compuesto:
  /// validation_status + is_active + is_available (asc, asc, asc).
  Stream<List<Professional>> watchApproved({int limit = 50}) {
    return collection
        .where('validation_status', isEqualTo: 'approved')
        .where('is_active', isEqualTo: true)
        .where('is_available', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map(mapQuery);
  }

  Stream<List<Professional>> watchSearchable({int limit = 50}) {
    return collection
        .where('validation_status', isEqualTo: 'approved')
        .where('is_active', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map(mapQuery);
  }

  Stream<List<Professional>> watchForAdmin({int limit = 100}) {
    return collection
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(mapQuery);
  }

  /// Búsqueda por especialidad (array-contains).
  /// Combinable con filtros por zona/rating del lado del cliente o con
  /// índices adicionales si se vuelve un patrón fijo.
  Stream<List<Professional>> watchBySpecialty(
    String specialty, {
    int limit = 50,
  }) {
    return collection
        .where('validation_status', isEqualTo: 'approved')
        .where('is_active', isEqualTo: true)
        .where('specialties', arrayContains: specialty)
        .orderBy('rating_avg', descending: true)
        .limit(limit)
        .snapshots()
        .map(mapQuery);
  }

  // ---------- documents ----------

  CollectionReference<Map<String, dynamic>> _documentsCol(String uid) =>
      collection.doc(uid).collection(FirestoreCollections.documents);

  Future<String> addDocument(String uid, ProfessionalDocument doc) async {
    final ref = await _documentsCol(uid).add(doc.toJson());
    return ref.id;
  }

  Stream<List<ProfessionalDocument>> watchDocuments(String uid) {
    return _documentsCol(uid).snapshots().map(
      (snap) => snap.docs
          .map((d) => ProfessionalDocument.fromJson({...d.data(), 'id': d.id}))
          .toList(),
    );
  }

  // ---------- availability_blocks ----------

  CollectionReference<Map<String, dynamic>> _availabilityCol(String uid) =>
      collection.doc(uid).collection(FirestoreCollections.availabilityBlocks);

  Future<String> addAvailabilityBlock(
    String uid,
    AvailabilityBlock block,
  ) async {
    final ref = await _availabilityCol(uid).add(block.toJson());
    return ref.id;
  }

  Stream<List<AvailabilityBlock>> watchAvailability(String uid) {
    return _availabilityCol(uid)
        .where('is_active', isEqualTo: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => AvailabilityBlock.fromJson({...d.data(), 'id': d.id}))
              .toList(),
        );
  }
}

@Riverpod(keepAlive: true)
ProfessionalsRepository professionalsRepository(Ref ref) =>
    ProfessionalsRepository(ref.watch(firebaseFirestoreProvider));
