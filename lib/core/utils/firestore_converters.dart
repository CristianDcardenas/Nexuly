import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Convierte `Timestamp` de Firestore a `DateTime` (y viceversa) al
/// (de)serializar con json_serializable.
///
/// Uso en un modelo Freezed:
/// ```dart
/// @TimestampConverter() required DateTime createdAt,
/// ```
class TimestampConverter implements JsonConverter<DateTime, Object?> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    throw ArgumentError('No se puede convertir a DateTime: $json');
  }

  @override
  Object toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Variante nullable para campos opcionales (ej: confirmed_at, started_at).
class NullableTimestampConverter
    implements JsonConverter<DateTime?, Object?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }

  @override
  Object? toJson(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);
}

/// Mantiene el `GeoPoint` de Firestore tal cual en el modelo.
/// No lo convertimos a lat/lng para no perder compatibilidad con consultas
/// geoespaciales (p.ej. geoflutterfire_plus).
class GeoPointConverter implements JsonConverter<GeoPoint, Object?> {
  const GeoPointConverter();

  @override
  GeoPoint fromJson(Object? json) {
    if (json is GeoPoint) return json;
    if (json is Map) {
      final lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
      final lng = (json['longitude'] as num?)?.toDouble() ?? 0.0;
      return GeoPoint(lat, lng);
    }
    throw ArgumentError('No se puede convertir a GeoPoint: $json');
  }

  @override
  Object toJson(GeoPoint gp) => gp;
}

class NullableGeoPointConverter implements JsonConverter<GeoPoint?, Object?> {
  const NullableGeoPointConverter();

  @override
  GeoPoint? fromJson(Object? json) {
    if (json == null) return null;
    if (json is GeoPoint) return json;
    if (json is Map) {
      final lat = (json['latitude'] as num?)?.toDouble();
      final lng = (json['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      return GeoPoint(lat, lng);
    }
    return null;
  }

  @override
  Object? toJson(GeoPoint? gp) => gp;
}
