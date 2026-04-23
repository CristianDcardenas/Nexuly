import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/firestore_converters.dart';

part 'admin_action.freezed.dart';
part 'admin_action.g.dart';

/// Colección `admin_actions` — auditoría de acciones administrativas.
@freezed
abstract class AdminAction with _$AdminAction {
  const factory AdminAction({
    required String id,
    required String adminId,
    required String
        actionType, // approve_professional | reject_professional | suspend_user | resolve_incident
    String? targetId,
    String? targetType, // user | professional | request
    String? notes,
    @TimestampConverter() required DateTime createdAt,
  }) = _AdminAction;

  factory AdminAction.fromJson(Map<String, dynamic> json) =>
      _$AdminActionFromJson(json);
}
