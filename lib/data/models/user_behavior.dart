import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/firestore_converters.dart';

part 'user_behavior.freezed.dart';
part 'user_behavior.g.dart';

/// Modelo de la colección `user_behavior`.
///
/// Reputación interna del usuario. NO se mezcla con `users` porque se actualiza
/// frecuentemente vía Cloud Functions y tiene reglas de seguridad distintas.
@freezed
abstract class UserBehavior with _$UserBehavior {
  const factory UserBehavior({
    required String uid,
    @Default(5.0) double behaviorScore, // 0.0 - 5.0
    @Default('standard') String trustLabel, // trusted | standard | incidents
    @Default(0) int noShowCount,
    @Default(0) int lateCancelCount,
    @Default(0) int totalServices,
    @Default(0) int completedServices,
    @Default(0.0) double lateCancelRate,
    @Default(0.0) double wouldAttendAgainRatio,
    @Default(0) int penaltyLevel, // 0..3
    @NullableTimestampConverter() DateTime? restrictionUntil,
    @NullableTimestampConverter() DateTime? lastEvaluatedAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _UserBehavior;

  factory UserBehavior.fromJson(Map<String, dynamic> json) =>
      _$UserBehaviorFromJson(json);
}
