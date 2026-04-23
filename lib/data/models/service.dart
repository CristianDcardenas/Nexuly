import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/firestore_converters.dart';
import 'shared_value_objects.dart';

part 'service.freezed.dart';
part 'service.g.dart';

/// Modelo de la colección `services` (catálogo ofrecido por profesionales).
@freezed
abstract class Service with _$Service {
  const factory Service({
    required String id,
    required String professionalId,
    required String name,
    String? description,
    required String category, // fisioterapia | enfermeria | cuidado | ...
    String? serviceType, // presencial | virtual
    required double price,
    required String currency, // ISO 4217: COP, USD, ...
    required int durationMin,
    @Default(true) bool isActive,
    ServiceMetadata? metadata,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);
}
