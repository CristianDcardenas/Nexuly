import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../storage/local_cache.dart';
import 'location_service.dart';
import 'qr_payload.dart';

enum ServiceEvidenceType { photo, video }

class ServiceEvidenceItem {
  const ServiceEvidenceItem({
    required this.id,
    required this.requestId,
    required this.type,
    required this.source,
    required this.base64,
    required this.mimeType,
    required this.savedAt,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.cachedLocation = false,
  });

  final String id;
  final String requestId;
  final ServiceEvidenceType type;
  final String source;
  final String base64;
  final String mimeType;
  final DateTime savedAt;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final bool cachedLocation;

  bool get hasLocation => latitude != null && longitude != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'request_id': requestId,
    'type': type.name,
    'source': source,
    'base64': base64,
    'mime_type': mimeType,
    'saved_at': savedAt.toIso8601String(),
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
    'cached_location': cachedLocation,
  };

  factory ServiceEvidenceItem.fromJson(Map<String, dynamic> json) {
    return ServiceEvidenceItem(
      id: json['id'] as String? ?? '',
      requestId: json['request_id'] as String? ?? '',
      type: json['type'] == ServiceEvidenceType.video.name
          ? ServiceEvidenceType.video
          : ServiceEvidenceType.photo,
      source: json['source'] as String? ?? 'camera',
      base64: json['base64'] as String? ?? '',
      mimeType: json['mime_type'] as String? ?? 'image/jpeg',
      savedAt:
          DateTime.tryParse(json['saved_at'] as String? ?? '') ??
          DateTime.now(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accuracyMeters: (json['accuracy_meters'] as num?)?.toDouble(),
      cachedLocation: json['cached_location'] as bool? ?? false,
    );
  }
}

class ServiceEvidenceService {
  ServiceEvidenceService(this._cache, this._locationService);

  final LocalCache _cache;
  final LocationService _locationService;
  final ImagePicker _picker = ImagePicker();

  List<ServiceEvidenceItem> getForRequest(String requestId) {
    final raw = _cache.getJson<List<dynamic>>(
      CacheKeys.serviceEvidence(requestId),
    );
    if (raw == null) return const [];
    return [
      for (final item in raw)
        ServiceEvidenceItem.fromJson(Map<String, dynamic>.from(item as Map)),
    ]..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  Future<ServiceEvidenceItem?> capturePhoto({
    required String requestId,
    required ImageSource source,
  }) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (file == null) return null;
    return _saveXFile(
      requestId: requestId,
      file: file,
      type: ServiceEvidenceType.photo,
      source: source.name,
    );
  }

  Future<ServiceEvidenceItem?> captureVideo({required String requestId}) async {
    final file = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 12),
    );
    if (file == null) return null;
    return _saveXFile(
      requestId: requestId,
      file: file,
      type: ServiceEvidenceType.video,
      source: ImageSource.camera.name,
    );
  }

  Future<void> saveQrCheckIn({
    required String requestId,
    required NexulyQrPayload payload,
    LocationResult? location,
  }) async {
    final stored = _cache.getJson<List<dynamic>>(
      CacheKeys.qrCheckIns(requestId),
    );
    final events = stored ?? <dynamic>[];
    events.add({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'request_id': requestId,
      'payload': payload.encode(),
      'saved_at': DateTime.now().toIso8601String(),
      if (location != null) ...{
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracy_meters': location.accuracyMeters,
        'cached_location': location.cached,
      },
    });
    await _cache.putJson(CacheKeys.qrCheckIns(requestId), events);
  }

  Future<ServiceEvidenceItem> _saveXFile({
    required String requestId,
    required XFile file,
    required ServiceEvidenceType type,
    required String source,
  }) async {
    final location = await _tryLocation();
    final bytes = await file.readAsBytes();
    final mimeType = _guessMimeType(file.name, file.mimeType, type);
    final item = ServiceEvidenceItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      requestId: requestId,
      type: type,
      source: source,
      base64: base64Encode(bytes),
      mimeType: mimeType,
      savedAt: DateTime.now(),
      latitude: location?.latitude,
      longitude: location?.longitude,
      accuracyMeters: location?.accuracyMeters,
      cachedLocation: location?.cached ?? false,
    );

    final current = getForRequest(requestId);
    final updated = [item, ...current].take(12).map((e) => e.toJson()).toList();
    await _cache.putJson(CacheKeys.serviceEvidence(requestId), updated);
    return item;
  }

  Future<LocationResult?> _tryLocation() async {
    try {
      return await _locationService.requestCurrent(
        timeout: const Duration(seconds: 6),
      );
    } catch (_) {
      return null;
    }
  }

  String _guessMimeType(
    String filename,
    String? xfileMime,
    ServiceEvidenceType type,
  ) {
    if (xfileMime != null && xfileMime.contains('/')) return xfileMime;
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    return type == ServiceEvidenceType.video ? 'video/mp4' : 'image/jpeg';
  }
}

final serviceEvidenceServiceProvider = Provider<ServiceEvidenceService>((ref) {
  return ServiceEvidenceService(
    ref.watch(localCacheProvider),
    ref.watch(locationServiceProvider),
  );
});

final serviceEvidenceProvider = FutureProvider.autoDispose
    .family<List<ServiceEvidenceItem>, String>((ref, requestId) async {
      return ref.watch(serviceEvidenceServiceProvider).getForRequest(requestId);
    });
