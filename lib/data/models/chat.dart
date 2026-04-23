import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/firestore_converters.dart';
import 'shared_value_objects.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

/// Colección `chats` — un chat por service_request.
@freezed
abstract class Chat with _$Chat {
  const factory Chat({
    required String id,
    required String requestId,
    required String userId,
    required String professionalId,
    String? lastMessagePreview,
    @NullableTimestampConverter() DateTime? lastMessageAt,
    @Default(0) int userUnreadCount,
    @Default(0) int professionalUnreadCount,
    @Default(true) bool isActive,
    @TimestampConverter() required DateTime createdAt,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}

/// Subcolección `chats/{id}/messages`.
@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    String? id,
    required String senderId,
    required String senderRole, // user | professional
    String? text,
    @Default(<MessageAttachment>[]) List<MessageAttachment> attachments,
    @NullableTimestampConverter() DateTime? readAt,
    @TimestampConverter() required DateTime createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
