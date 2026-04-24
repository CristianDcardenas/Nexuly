import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/firestore_converters.dart';

part 'review.freezed.dart';
part 'review.g.dart';

/// Modelo de la colección `reviews` — evaluaciones bidireccionales.
///
/// `isPublic = true`  → reseña visible (user → professional).
/// `isPublic = false` → evaluación interna (professional → user),
/// alimenta `user_behavior`.
@freezed
abstract class Review with _$Review {
  const factory Review({
    required String id,
    required String requestId,
    required String authorId,
    required String targetId,
    required String authorRole, // user | professional
    required String targetRole, // user | professional
    int? rating, // 1-5, sólo aplica cuando el target es profesional
    String? comment, // visible sólo si author = user
    required bool isPublic,

    /// Nombre denormalizado del autor (primer nombre + inicial del apellido).
    /// Se copia al momento de crear la review para mostrarlo sin joins.
    String? authorName,

    // Campos del flujo profesional → usuario (checkboxes de evaluación interna)
    bool? punctualityOk,
    bool? respectfulOk,
    bool? conditionsOk,
    bool? wouldAttendAgain,

    @TimestampConverter() required DateTime createdAt,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) =>
      _$ReviewFromJson(json);
}
