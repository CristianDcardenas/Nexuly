import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/firestore_converters.dart';

part 'service_request.freezed.dart';
part 'service_request.g.dart';

/// Colección `service_requests` — núcleo del flujo de Nexuly.
///
/// Modela solicitudes (no citas rígidas) para soportar tanto el flujo
/// manual del MVP como la asignación automática futura sin refactor.
@freezed
abstract class ServiceRequest with _$ServiceRequest {
  const factory ServiceRequest({
    required String id,
    required String userId,
    String? professionalId, // null si pending_assignment
    required String serviceId,

    /// Ver máquina de estados en ServiceRequestStatus.
    @Default('CREATED') String status,

    /// manual (MVP) | open (futuro)
    @Default('manual') String requestType,

    @TimestampConverter() required DateTime requestedDate,
    @NullableTimestampConverter() DateTime? requestedEndDate,

    @GeoPointConverter() required GeoPoint location,
    String? locationAddress,

    /// Futuro: descripción libre del usuario (para IA).
    String? userNeedDescription,

    /// Categoría sugerida por la IA a partir del user_need_description.
    String? aiSuggestedService,
    double? aiConfidence, // 0.0 - 1.0

    double? priceQuoted,
    String? currency,

    /// Bloqueo anti double-booking durante confirmación.
    @NullableTimestampConverter() DateTime? slotLockedUntil,

    String? cancellationReason,
    String? cancelledBy, // user | professional | system
    String? noShowBy, // user | professional

    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    @NullableTimestampConverter() DateTime? confirmedAt,
    @NullableTimestampConverter() DateTime? startedAt,
    @NullableTimestampConverter() DateTime? completedAt,
  }) = _ServiceRequest;

  factory ServiceRequest.fromJson(Map<String, dynamic> json) =>
      _$ServiceRequestFromJson(json);
}

/// Subcolección `service_requests/{id}/status_history`.
/// Trazabilidad completa de transiciones de estado.
@freezed
abstract class StatusHistoryEntry with _$StatusHistoryEntry {
  const factory StatusHistoryEntry({
    String? id,
    String? fromStatus,
    required String toStatus,
    required String changedBy, // user | professional | system
    String? changedById,
    String? reason,
    @TimestampConverter() required DateTime timestamp,
  }) = _StatusHistoryEntry;

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$StatusHistoryEntryFromJson(json);
}
