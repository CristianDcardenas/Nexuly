import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/firestore_converters.dart';
import 'shared_value_objects.dart';

part 'notification_record.freezed.dart';
part 'notification_record.g.dart';

/// Colección `notifications` — registro de notificaciones enviadas.
/// Se llama `NotificationRecord` para no chocar con `Notification` de Material.
@freezed
abstract class NotificationRecord with _$NotificationRecord {
  const factory NotificationRecord({
    required String id,
    required String recipientId,
    required String recipientRole, // user | professional | admin
    required String
        type, // request_created | confirmed | rejected | reminder | new_message | status_change
    required String title,
    String? body,
    NotificationData? data,
    @Default(<String>[]) List<String> channel, // push | email | sms
    @Default(false) bool isRead,
    @NullableTimestampConverter() DateTime? readAt,
    @TimestampConverter() required DateTime sentAt,
  }) = _NotificationRecord;

  factory NotificationRecord.fromJson(Map<String, dynamic> json) =>
      _$NotificationRecordFromJson(json);
}
