import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_value_objects.freezed.dart';
part 'shared_value_objects.g.dart';

/// Contacto de emergencia (dentro de users.emergency_contact).
@freezed
abstract class EmergencyContact with _$EmergencyContact {
  const factory EmergencyContact({
    required String name,
    required String phone,
    String? relation,
  }) = _EmergencyContact;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactFromJson(json);
}

/// Configuración de canales de notificación del usuario.
@freezed
abstract class NotificationsConfig with _$NotificationsConfig {
  const factory NotificationsConfig({
    @Default(true) bool push,
    @Default(true) bool email,
    @Default(false) bool sms,
  }) = _NotificationsConfig;

  factory NotificationsConfig.fromJson(Map<String, dynamic> json) =>
      _$NotificationsConfigFromJson(json);
}

/// Preferencias de UI/UX del usuario.
@freezed
abstract class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(false) bool darkMode,
    @Default('es') String language,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

/// Metadata extensible del servicio (requisitos, complejidad, etc).
@freezed
abstract class ServiceMetadata with _$ServiceMetadata {
  const factory ServiceMetadata({
    @Default(<String>[]) List<String> requirements,
    String? complexity,
    @Default(<String>[]) List<String> materials,
    @Default(<String>[]) List<String> tags,
    String? notes,
  }) = _ServiceMetadata;

  factory ServiceMetadata.fromJson(Map<String, dynamic> json) =>
      _$ServiceMetadataFromJson(json);
}

/// Adjunto en un mensaje de chat.
@freezed
abstract class MessageAttachment with _$MessageAttachment {
  const factory MessageAttachment({
    required String url,
    required String type, // image, document, audio...
    String? name,
  }) = _MessageAttachment;

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      _$MessageAttachmentFromJson(json);
}

/// Categoría sugerida por la IA en ai_recommendations.suggested_categories[].
@freezed
abstract class SuggestedCategory with _$SuggestedCategory {
  const factory SuggestedCategory({
    required String category,
    required double confidence,
    String? reason,
  }) = _SuggestedCategory;

  factory SuggestedCategory.fromJson(Map<String, dynamic> json) =>
      _$SuggestedCategoryFromJson(json);
}

/// Payload de deep-link para una notificación.
@freezed
abstract class NotificationData with _$NotificationData {
  const factory NotificationData({
    String? requestId,
    String? chatId,
    String? deepLink,
  }) = _NotificationData;

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataFromJson(json);
}
