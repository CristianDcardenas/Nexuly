import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/firestore_converters.dart';
import 'shared_value_objects.dart';

part 'ai_recommendation.freezed.dart';
part 'ai_recommendation.g.dart';

/// Colección `ai_recommendations` — log de sugerencias de la IA.
///
/// El campo `feedback` permite retroalimentar el modelo con la respuesta real
/// del usuario para mejorar recomendaciones futuras.
@freezed
abstract class AiRecommendation with _$AiRecommendation {
  const factory AiRecommendation({
    required String id,
    required String userId,
    String? inputText,
    @Default(<SuggestedCategory>[])
    List<SuggestedCategory> suggestedCategories,
    @Default(<String>[]) List<String> recommendedProfessionals,
    @Default(1) int recommendationLevel, // 1=básico, 2=personalizado, 3=orientación
    String? feedback, // helpful | not_helpful | null
    @TimestampConverter() required DateTime createdAt,
  }) = _AiRecommendation;

  factory AiRecommendation.fromJson(Map<String, dynamic> json) =>
      _$AiRecommendationFromJson(json);
}
