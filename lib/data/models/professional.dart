import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/firestore_converters.dart';

part 'professional.freezed.dart';
part 'professional.g.dart';

/// Modelo de la colección `professionals`.
@freezed
abstract class Professional with _$Professional {
  const factory Professional({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    String? photoUrl,
    String? bio,
    @Default(<String>[]) List<String> specialties,

    /// pending | approved | rejected | suspended
    @Default('pending') String validationStatus,
    String? rejectionReason,
    @Default(0) int rejectionCount,

    @Default(true) bool isActive,
    @Default(false) bool isAvailable,
    @Default(false) bool doNotDisturb,

    @GeoPointConverter() required GeoPoint location,

    /// radius | zones
    @Default('radius') String coverageType,
    double? coverageRadiusKm,
    @Default(<String>[]) List<String> coverageZones,

    /// Nivel mínimo de verificación que acepta del usuario.
    String? minUserTrustLevel,

    @Default(0.0) double ratingAvg,
    @Default(0) int ratingCount,
    double? responseTimeAvgMin,
    @Default(0.0) double acceptanceRate,
    @Default(0.0) double completionRate,

    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Professional;

  factory Professional.fromJson(Map<String, dynamic> json) =>
      _$ProfessionalFromJson(json);
}

/// Subcolección `professionals/{uid}/documents`.
@freezed
abstract class ProfessionalDocument with _$ProfessionalDocument {
  const factory ProfessionalDocument({
    String? id, // id del documento Firestore (no persistido dentro del doc)
    required String type, // id_card | license | certificate
    required String storageUrl,
    @Default('pending') String status, // pending | verified | rejected
    @NullableTimestampConverter() DateTime? uploadedAt,
    @NullableTimestampConverter() DateTime? verifiedAt,
    String? adminNotes,
  }) = _ProfessionalDocument;

  factory ProfessionalDocument.fromJson(Map<String, dynamic> json) =>
      _$ProfessionalDocumentFromJson(json);
}

/// Subcolección `professionals/{uid}/availability_blocks`.
@freezed
abstract class AvailabilityBlock with _$AvailabilityBlock {
  const factory AvailabilityBlock({
    String? id,
    required int dayOfWeek, // 0=dom .. 6=sab
    required String startTime, // 'HH:MM'
    required String endTime, // 'HH:MM'
    @Default(true) bool isActive,
    @NullableTimestampConverter() DateTime? validFrom,
    @NullableTimestampConverter() DateTime? validUntil,
  }) = _AvailabilityBlock;

  factory AvailabilityBlock.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityBlockFromJson(json);
}

/// Subcolección `professionals/{uid}/blocked_users`.
@freezed
abstract class BlockedUser with _$BlockedUser {
  const factory BlockedUser({
    required String userId,
    @TimestampConverter() required DateTime blockedAt,
    String? reason,
  }) = _BlockedUser;

  factory BlockedUser.fromJson(Map<String, dynamic> json) =>
      _$BlockedUserFromJson(json);
}
