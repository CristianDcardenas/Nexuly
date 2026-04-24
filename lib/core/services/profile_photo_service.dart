import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/local_cache.dart';

part 'profile_photo_service.g.dart';

/// Servicio de foto de perfil.
///
/// En R1 mantenemos las fotos **solo localmente** (en Hive, en base64) porque:
/// - Firebase Storage requiere plan Blaze (no lo tenemos).
/// - Permite demostrar "persistencia offline" sin backend.
///
/// Cuando activemos Storage, cambia la estrategia a: subir a Storage, guardar
/// URL en Firestore, y cachear la URL (no el base64).
class ProfilePhotoService {
  ProfilePhotoService(this._cache);
  final LocalCache _cache;

  final ImagePicker _picker = ImagePicker();

  static const String _photoKeyPrefix = 'profile_photo_';

  /// Pide al usuario elegir una foto desde galería o cámara y la guarda
  /// localmente asociada al `uid`. Retorna la foto en base64 o null si el
  /// usuario cancela.
  Future<String?> pickAndSave({
    required String uid,
    required ImageSource source,
  }) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 75, // comprimir para no llenar Hive
      maxWidth: 800,
      maxHeight: 800,
    );

    if (file == null) return null;

    // Convertir a base64 (funciona igual en web y mobile).
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);

    // Guardar en Hive con TTL "infinito" (hasta que el user la cambie).
    final mimeType = _guessMimeType(file.name, file.mimeType);
    await _cache.putJson(_photoKeyPrefix + uid, {
      'base64': base64Str,
      'mimeType': mimeType,
      'savedAt': DateTime.now().toIso8601String(),
    });

    return 'data:$mimeType;base64,$base64Str';
  }

  /// Recupera la foto local del usuario como data URL lista para usar en
  /// un `Image.network(dataUrl)`.
  String? getDataUrl(String uid) {
    final cached = _cache.getJson<Map<String, dynamic>>(_photoKeyPrefix + uid);
    if (cached == null) return null;
    final base64Str = cached['base64'] as String?;
    final mimeType = cached['mimeType'] as String? ?? 'image/jpeg';
    if (base64Str == null) return null;
    return 'data:$mimeType;base64,$base64Str';
  }

  /// Borra la foto local del usuario.
  Future<void> remove(String uid) async {
    await _cache.delete(_photoKeyPrefix + uid);
  }

  /// Intenta inferir el mime type desde el nombre del archivo o del XFile.
  String _guessMimeType(String filename, String? xfileMime) {
    if (xfileMime != null && xfileMime.startsWith('image/')) return xfileMime;
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}

/// Provider del servicio.
@Riverpod(keepAlive: true)
ProfilePhotoService profilePhotoService(Ref ref) {
  return ProfilePhotoService(ref.watch(localCacheProvider));
}
