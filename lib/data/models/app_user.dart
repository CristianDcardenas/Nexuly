import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/firestore_converters.dart';
import 'shared_value_objects.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Modelo de la colección `users`.
///
/// El nombre es `AppUser` para no chocar con `User` de `firebase_auth`.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    /// Firebase Auth UID — ID del documento.
    required String uid,
    required String fullName,
    required String email,
    String? phone,
    String? photoUrl,

    /// Lista de proveedores: ['email','google','apple'].
    @Default(<String>[]) List<String> authProviders,

    /// basic | verified | trusted
    @Default('basic') String verificationLevel,

    @Default(true) bool isActive,
    @Default(false) bool isAnonymous,

    @NullableGeoPointConverter() GeoPoint? location,
    @NullableTimestampConverter() DateTime? locationUpdatedAt,

    EmergencyContact? emergencyContact,

    @Default(false) bool consentMedicalData,
    @NullableTimestampConverter() DateTime? consentAt,

    NotificationsConfig? notificationsConfig,
    UserPreferences? preferences,

    @NullableTimestampConverter() DateTime? termsAcceptedAt,

    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}

/// Subcolección `users/{uid}/medical_profile` (documento único).
@freezed
abstract class MedicalProfile with _$MedicalProfile {
  const factory MedicalProfile({
    @Default(<String>[]) List<String> allergies,
    @Default(<String>[]) List<String> chronicConditions,
    @Default(<String>[]) List<String> currentMedications,
    String? bloodType,
    String? notes,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _MedicalProfile;

  factory MedicalProfile.fromJson(Map<String, dynamic> json) =>
      _$MedicalProfileFromJson(json);
}

/// Subcolección `users/{uid}/blocked_professionals`.
@freezed
abstract class BlockedProfessional with _$BlockedProfessional {
  const factory BlockedProfessional({
    required String professionalId,
    @TimestampConverter() required DateTime blockedAt,
    String? reason,
  }) = _BlockedProfessional;

  factory BlockedProfessional.fromJson(Map<String, dynamic> json) =>
      _$BlockedProfessionalFromJson(json);
}
