import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/firestore_collections.dart';
import '../../core/enums/domain_enums.dart';
import '../../core/errors/failures.dart';
import '../../core/providers/firebase_providers.dart';
import '../models/service_request.dart';
import 'base_repository.dart';

part 'service_requests_repository.g.dart';

class ServiceRequestsRepository
    extends BaseFirestoreRepository<ServiceRequest> {
  ServiceRequestsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.serviceRequests);

  @override
  ServiceRequest fromJson(Map<String, dynamic> json) =>
      ServiceRequest.fromJson(json);

  @override
  Map<String, dynamic> toJson(ServiceRequest model) => model.toJson();

  /// Historial reciente global para dashboard administrativo.
  Stream<List<ServiceRequest>> watchRecent({int limit = 400}) {
    return collection
        .orderBy('requested_date', descending: true)
        .limit(limit)
        .snapshots()
        .map(mapQuery);
  }

  /// Historial del usuario (requiere índice: user_id + status + created_at).
  Stream<List<ServiceRequest>> watchByUser(String userId, {int limit = 50}) {
    return collection
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(mapQuery);
  }

  /// Agenda del profesional (requiere índice:
  /// professional_id + status + requested_date).
  Stream<List<ServiceRequest>> watchByProfessional(
    String professionalId, {
    int limit = 50,
  }) {
    return collection
        .where('professional_id', isEqualTo: professionalId)
        .orderBy('requested_date', descending: false)
        .limit(limit)
        .snapshots()
        .map(mapQuery);
  }

  /// Cambia el estado del request y registra la transición en status_history
  /// en una única transacción atómica. Valida transiciones permitidas.
  Future<void> changeStatus({
    required String requestId,
    required ServiceRequestStatus to,
    required ActorRole changedBy,
    required String changedById,
    String? reason,
  }) async {
    final ref = collection.doc(requestId);
    final historyRef = ref.collection(FirestoreCollections.statusHistory).doc();

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw const NotFoundFailure('Service request no existe');
      }
      final current = ServiceRequestStatus.fromValue(
        snap.data()?['status'] as String?,
      );
      if (!current.allowedTransitions.contains(to)) {
        throw ValidationFailure(
          'Transición inválida: ${current.value} → ${to.value}',
        );
      }

      final now = FieldValue.serverTimestamp();

      tx
        ..update(ref, {
          'status': to.value,
          'updated_at': now,
          if (to == ServiceRequestStatus.confirmed) 'confirmed_at': now,
          if (to == ServiceRequestStatus.inProgress) 'started_at': now,
          if (to == ServiceRequestStatus.completed) 'completed_at': now,
          if (to == ServiceRequestStatus.cancelled && reason != null)
            'cancellation_reason': reason,
          if (to == ServiceRequestStatus.cancelled)
            'cancelled_by': changedBy.value,
          if (to == ServiceRequestStatus.noShow) 'no_show_by': changedBy.value,
        })
        ..set(historyRef, {
          'from_status': current.value,
          'to_status': to.value,
          'changed_by': changedBy.value,
          'changed_by_id': changedById,
          if (reason != null) 'reason': reason,
          'timestamp': now,
        });
    });
  }
}

@Riverpod(keepAlive: true)
ServiceRequestsRepository serviceRequestsRepository(Ref ref) =>
    ServiceRequestsRepository(ref.watch(firebaseFirestoreProvider));
