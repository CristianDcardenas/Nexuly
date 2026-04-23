/// Nombres de colecciones y subcolecciones Firestore en un único lugar.
/// Usar siempre estas constantes en lugar de strings literales.
class FirestoreCollections {
  FirestoreCollections._();

  // Colecciones raíz
  static const String users = 'users';
  static const String userBehavior = 'user_behavior';
  static const String professionals = 'professionals';
  static const String services = 'services';
  static const String serviceRequests = 'service_requests';
  static const String reviews = 'reviews';
  static const String chats = 'chats';
  static const String notifications = 'notifications';
  static const String adminActions = 'admin_actions';
  static const String aiRecommendations = 'ai_recommendations';

  // Subcolecciones
  static const String medicalProfile = 'medical_profile';
  static const String blockedProfessionals = 'blocked_professionals';
  static const String documents = 'documents';
  static const String availabilityBlocks = 'availability_blocks';
  static const String blockedUsers = 'blocked_users';
  static const String statusHistory = 'status_history';
  static const String messages = 'messages';

  // Documento único dentro de medical_profile
  static const String medicalProfileDocId = 'profile';
}
