import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_cache.g.dart';

/// Nombres de las "boxes" de Hive que usamos en la app.
///
/// Una box es como una tabla: almacena pares clave-valor. Cada feature
/// que necesita cache persistente declara su box aquí.
abstract class HiveBoxes {
  HiveBoxes._();

  /// Cache offline genérico: JSON serializable de listas y docs de Firestore.
  /// Se usa para mostrar los últimos profesionales vistos cuando no hay red.
  static const String cache = 'nexuly_cache';

  /// Preferencias del usuario (ubicación elegida, categoría por defecto, etc).
  static const String prefs = 'nexuly_prefs';

  /// Cola de acciones pendientes (ej: una reseña que no se pudo enviar).
  /// No implementamos sync en R1, pero dejamos el box listo.
  static const String outbox = 'nexuly_outbox';
}

/// Llaves canónicas dentro del box `cache`.
abstract class CacheKeys {
  CacheKeys._();

  /// JSON: lista de profesionales visitados/vistos recientemente.
  static const String recentProfessionals = 'recent_professionals';

  /// JSON: última ubicación conocida del usuario.
  static const String lastLocation = 'last_location';

  /// JSON: evidencias offline capturadas para un servicio.
  static String serviceEvidence(String requestId) =>
      'service_evidence_$requestId';

  /// JSON: eventos QR/check-in capturados localmente.
  static String qrCheckIns(String requestId) => 'qr_checkins_$requestId';

  /// JSON: resultados cacheados del home (últimos profs recomendados).
  static const String homeSnapshot = 'home_snapshot';

  /// JSON: ultimo dashboard administrativo calculado.
  static const String analyticsAdminSnapshot = 'analytics_admin_snapshot';

  /// JSON: ultimo dashboard calculado para un profesional.
  static String analyticsProfessionalSnapshot(String uid) =>
      'analytics_professional_snapshot_$uid';
}

/// Envuelve un valor con su timestamp para poder implementar TTL.
class CachedEntry<T> {
  const CachedEntry({required this.value, required this.savedAt});

  final T value;
  final DateTime savedAt;

  bool isFresherThan(Duration maxAge) =>
      DateTime.now().difference(savedAt) < maxAge;

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) valueToJson) => {
    'v': valueToJson(value),
    't': savedAt.millisecondsSinceEpoch,
  };

  static CachedEntry<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) valueFromJson,
  ) => CachedEntry<T>(
    value: valueFromJson(json['v'] as Map<String, dynamic>),
    savedAt: DateTime.fromMillisecondsSinceEpoch(json['t'] as int),
  );
}

/// Servicio de cache local basado en Hive.
///
/// ¿Por qué Hive y no SharedPreferences?
/// - Hive guarda JSON arbitrario (listas, objetos anidados).
/// - Es rápido y persistente entre sesiones.
/// - Funciona en web, Android, iOS, desktop.
///
/// Uso típico:
/// ```dart
/// final cache = ref.read(localCacheProvider);
/// await cache.putJson(CacheKeys.recentProfessionals, [...]);
/// final cached = cache.getJson(CacheKeys.recentProfessionals);
/// ```
class LocalCache {
  LocalCache(this._box);
  final Box<dynamic> _box;

  /// Guarda un valor JSON (Map o List) bajo una clave.
  Future<void> putJson(String key, Object? value) async {
    if (value == null) {
      await _box.delete(key);
      return;
    }
    await _box.put(key, jsonEncode(value));
  }

  /// Lee un valor JSON. Devuelve null si no existe o si falla el parseo.
  T? getJson<T>(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw as String) as T;
    } catch (e) {
      if (kDebugMode) debugPrint('Cache parse error for $key: $e');
      return null;
    }
  }

  /// Guarda un valor con timestamp (para TTL).
  Future<void> putWithTimestamp(String key, Object? value) async {
    if (value == null) {
      await _box.delete(key);
      return;
    }
    await _box.put(
      key,
      jsonEncode({'v': value, 't': DateTime.now().millisecondsSinceEpoch}),
    );
  }

  /// Lee un valor con TTL. Devuelve null si no existe, no se puede parsear,
  /// o si excede [maxAge].
  T? getFreshJson<T>(String key, Duration maxAge) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
      final savedAt = DateTime.fromMillisecondsSinceEpoch(decoded['t'] as int);
      if (DateTime.now().difference(savedAt) > maxAge) return null;
      return decoded['v'] as T;
    } catch (e) {
      if (kDebugMode) debugPrint('Cache TTL parse error for $key: $e');
      return null;
    }
  }

  Future<void> delete(String key) => _box.delete(key);

  Future<void> clearAll() => _box.clear();

  /// Todas las claves (útil para debug/inspección).
  Iterable<String> keys() => _box.keys.cast<String>();
}

/// Inicializa Hive y abre todas las boxes necesarias.
///
/// Debe llamarse en `main.dart` **antes** de `runApp(...)`.
Future<void> initializeLocalStorage() async {
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<dynamic>(HiveBoxes.cache),
    Hive.openBox<dynamic>(HiveBoxes.prefs),
    Hive.openBox<dynamic>(HiveBoxes.outbox),
  ]);
}

// --- Providers ------------------------------------------------------------

/// Provider del cache principal (JSON genérico).
@Riverpod(keepAlive: true)
LocalCache localCache(Ref ref) {
  return LocalCache(Hive.box<dynamic>(HiveBoxes.cache));
}

/// Provider del cache de preferencias.
@Riverpod(keepAlive: true)
LocalCache preferencesCache(Ref ref) {
  return LocalCache(Hive.box<dynamic>(HiveBoxes.prefs));
}
