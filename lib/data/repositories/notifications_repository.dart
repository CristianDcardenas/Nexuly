import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/firestore_collections.dart';
import '../../core/providers/firebase_providers.dart';
import '../models/notification_record.dart';
import 'base_repository.dart';

part 'notifications_repository.g.dart';

class NotificationsRepository
    extends BaseFirestoreRepository<NotificationRecord> {
  NotificationsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.notifications);

  @override
  NotificationRecord fromJson(Map<String, dynamic> json) =>
      NotificationRecord.fromJson(json);

  @override
  Map<String, dynamic> toJson(NotificationRecord model) => model.toJson();

  /// Notificaciones del usuario, no leídas primero.
  /// Requiere índice: recipient_id + is_read + sent_at.
  Stream<List<NotificationRecord>> watchForRecipient(
    String recipientId, {
    int limit = 50,
  }) {
    return collection
        .where('recipient_id', isEqualTo: recipientId)
        .orderBy('sent_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(mapQuery);
  }

  Future<void> markRead(String id) => update(id, {
        'is_read': true,
        'read_at': FieldValue.serverTimestamp(),
      });
}

@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(Ref ref) =>
    NotificationsRepository(ref.watch(firebaseFirestoreProvider));
