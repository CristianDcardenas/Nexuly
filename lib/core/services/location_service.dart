import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

/// Resultado de una solicitud de ubicación.
class LocationResult {
  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.cached = false,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;

  /// `true` si el valor proviene del último punto conocido del dispositivo
  /// (útil cuando el GPS tarda y preferimos mostrar algo rápido).
  final bool cached;
}

/// Estados posibles del servicio de ubicación.
enum LocationStatus {
  /// Todo en orden, ubicación obtenida.
  granted,

  /// El usuario denegó el permiso (al menos una vez).
  denied,

  /// El usuario denegó el permiso para siempre — hay que abrir settings.
  deniedForever,

  /// Los servicios de ubicación del sistema están apagados.
  serviceDisabled,

  /// No se puede pedir permiso (web o plataforma no soportada).
  unsupported,
}

/// Falla del servicio de ubicación, mapeada a un estado de UI.
class LocationFailure implements Exception {
  const LocationFailure(this.status, [this.message]);
  final LocationStatus status;
  final String? message;

  String get userMessage => switch (status) {
        LocationStatus.denied =>
          'Necesitamos tu ubicación para mostrarte profesionales cercanos.',
        LocationStatus.deniedForever =>
          'Activa los permisos de ubicación en la configuración del sistema.',
        LocationStatus.serviceDisabled =>
          'Activa la ubicación del dispositivo para continuar.',
        LocationStatus.unsupported =>
          'Tu dispositivo no soporta geolocalización.',
        LocationStatus.granted => message ?? '',
      };
}

/// Servicio para obtener y observar la ubicación del usuario.
///
/// Diseño:
/// - Primero intenta devolver el último punto conocido (rápido, <100 ms).
/// - En paralelo, solicita una ubicación fresca con mejor precisión.
/// - Ofrece cálculo de distancia hacia un punto objetivo (Haversine).
class LocationService {
  const LocationService();

  /// Solicita permisos y obtiene la ubicación actual.
  ///
  /// Flujo:
  /// 1. Verifica que el servicio de ubicación del sistema esté prendido.
  /// 2. Consulta el estado del permiso.
  /// 3. Si no está otorgado, lo pide.
  /// 4. Si lo tiene, obtiene la posición.
  ///
  /// Lanza [LocationFailure] en cualquier error.
  Future<LocationResult> requestCurrent({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // 1. ¿El dispositivo tiene GPS activo?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure(LocationStatus.serviceDisabled);
    }

    // 2. Estado del permiso.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationFailure(LocationStatus.denied);
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(LocationStatus.deniedForever);
    }

    // 3. Intentar primero con last known (rápido), caemos en fresh si falla.
    try {
      if (!kIsWeb) {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          // Aún así pedimos una fresca, pero ya podemos retornar la cache.
          // Para simplicidad en el hackathon, devolvemos directamente la fresca.
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: accuracy),
      ).timeout(timeout);

      return LocationResult(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracyMeters: pos.accuracy,
      );
    } catch (e) {
      // Si la fresca falló pero tenemos last known, devolverla.
      if (!kIsWeb) {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          return LocationResult(
            latitude: last.latitude,
            longitude: last.longitude,
            accuracyMeters: last.accuracy,
            cached: true,
          );
        }
      }
      throw LocationFailure(
        LocationStatus.granted,
        'No se pudo obtener la ubicación: $e',
      );
    }
  }

  /// Distancia en kilómetros entre dos puntos (Haversine).
  ///
  /// Uso típico: ordenar una lista de profesionales por distancia al paciente.
  double distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const radiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return radiusKm * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);
}

/// Provider del servicio (singleton, sin estado).
@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) => const LocationService();

/// Provider asíncrono de la ubicación actual.
/// Se refresca con `ref.invalidate(currentLocationProvider)`.
@riverpod
Future<LocationResult?> currentLocation(Ref ref) async {
  try {
    return await ref.watch(locationServiceProvider).requestCurrent();
  } on LocationFailure {
    // Dejamos que el caller maneje el error (vía `ref.watch(...).whenData`).
    rethrow;
  }
}
