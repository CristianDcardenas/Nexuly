import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/firestore_collections.dart';
import '../../core/providers/firebase_providers.dart';
import '../models/chat.dart';
import 'base_repository.dart';

part 'chats_repository.g.dart';

class ChatsRepository extends BaseFirestoreRepository<Chat> {
  ChatsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.chats);

  @override
  Chat fromJson(Map<String, dynamic> json) => Chat.fromJson(json);

  @override
  Map<String, dynamic> toJson(Chat model) => model.toJson();

  /// Bandeja de entrada del usuario.
  /// Requiere índice: user_id + last_message_at (desc).
  Stream<List<Chat>> watchForUser(String userId) {
    return collection
        .where('user_id', isEqualTo: userId)
        .where('is_active', isEqualTo: true)
        .orderBy('last_message_at', descending: true)
        .snapshots()
        .map(mapQuery);
  }

  /// Bandeja de entrada del profesional.
  Stream<List<Chat>> watchForProfessional(String professionalId) {
    return collection
        .where('professional_id', isEqualTo: professionalId)
        .where('is_active', isEqualTo: true)
        .orderBy('last_message_at', descending: true)
        .snapshots()
        .map(mapQuery);
  }

  // ---------- messages ----------

  CollectionReference<Map<String, dynamic>> _messagesCol(String chatId) =>
      collection.doc(chatId).collection(FirestoreCollections.messages);

  /// Envía un mensaje y actualiza el chat padre en una sola operación batch.
  Future<void> sendMessage({
    required String chatId,
    required ChatMessage message,
    required String recipientField, // 'user_unread_count' | 'professional_unread_count'
  }) async {
    final batch = _firestore.batch();
    final msgRef = _messagesCol(chatId).doc();
    batch
      ..set(msgRef, message.toJson())
      ..update(collection.doc(chatId), {
        'last_message_preview':
            message.text ?? (message.attachments.isNotEmpty ? '📎 Adjunto' : ''),
        'last_message_at': FieldValue.serverTimestamp(),
        recipientField: FieldValue.increment(1),
      });
    await batch.commit();
  }

  /// Paginación de mensajes (más recientes primero).
  /// Usa `startAfterDocument` para la siguiente página.
  Stream<List<ChatMessage>> watchMessages(String chatId, {int limit = 30}) {
    return _messagesCol(chatId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ChatMessage.fromJson({...d.data(), 'id': d.id}))
              .toList(),
        );
  }

  /// Resetea contador de no leídos del rol indicado.
  Future<void> markRead(String chatId, {required bool asUser}) {
    return collection.doc(chatId).update({
      asUser ? 'user_unread_count' : 'professional_unread_count': 0,
    });
  }
}

@Riverpod(keepAlive: true)
ChatsRepository chatsRepository(Ref ref) =>
    ChatsRepository(ref.watch(firebaseFirestoreProvider));
