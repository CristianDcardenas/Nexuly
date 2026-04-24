import 'dart:convert';

/// Tipos de QR soportados por Nexuly.
///
/// Cada QR lleva un payload JSON con un campo `type` que permite distinguir
/// qué acción ejecutar al escanearlo.
enum NexulyQrType {
  /// Identifica un servicio activo. Lo genera el paciente, lo escanea el
  /// profesional al llegar al domicilio para marcar "check-in".
  serviceCheckIn('service_checkin'),

  /// Identifica a un profesional (para compartir su perfil vía QR).
  professionalProfile('professional_profile'),

  /// Identifica una cita/reserva (para mostrar resumen sin abrir sesión).
  bookingReference('booking_reference');

  const NexulyQrType(this.code);
  final String code;

  static NexulyQrType? fromCode(String code) {
    for (final type in NexulyQrType.values) {
      if (type.code == code) return type;
    }
    return null;
  }
}

/// Payload genérico de un QR de Nexuly.
///
/// Se serializa como JSON dentro del QR. Ejemplo:
/// ```json
/// {
///   "app": "nexuly",
///   "v": 1,
///   "type": "service_checkin",
///   "data": { "request_id": "abc123", "patient_uid": "xyz" }
/// }
/// ```
///
/// El prefijo `app: "nexuly"` permite que un escáner distinga nuestros QR
/// de otros (ejemplo: un QR genérico de Wi-Fi o un link).
class NexulyQrPayload {
  const NexulyQrPayload({
    required this.type,
    required this.data,
    this.version = 1,
  });

  final NexulyQrType type;
  final Map<String, dynamic> data;
  final int version;

  /// Serializa a texto para meter en el QR.
  String encode() {
    return jsonEncode({
      'app': 'nexuly',
      'v': version,
      'type': type.code,
      'data': data,
    });
  }

  /// Deserializa un texto escaneado. Retorna `null` si no es un QR de Nexuly
  /// o si está mal formado.
  static NexulyQrPayload? tryDecode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['app'] != 'nexuly') return null;

      final typeCode = decoded['type'];
      if (typeCode is! String) return null;
      final type = NexulyQrType.fromCode(typeCode);
      if (type == null) return null;

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) return null;

      return NexulyQrPayload(
        type: type,
        data: data,
        version: decoded['v'] as int? ?? 1,
      );
    } catch (_) {
      return null;
    }
  }

  // --- Constructores específicos por tipo ---

  /// QR que muestra el paciente al profesional cuando llega al domicilio.
  /// Lleva el `request_id` y el `uid` del paciente para verificar que el
  /// servicio corresponde.
  factory NexulyQrPayload.serviceCheckIn({
    required String requestId,
    required String patientUid,
    required String serviceId,
  }) =>
      NexulyQrPayload(
        type: NexulyQrType.serviceCheckIn,
        data: {
          'request_id': requestId,
          'patient_uid': patientUid,
          'service_id': serviceId,
          'generated_at': DateTime.now().toIso8601String(),
        },
      );

  /// QR del perfil de un profesional para compartir fácilmente.
  factory NexulyQrPayload.professionalProfile({
    required String professionalUid,
    required String professionalName,
  }) =>
      NexulyQrPayload(
        type: NexulyQrType.professionalProfile,
        data: {
          'uid': professionalUid,
          'name': professionalName,
        },
      );
}
