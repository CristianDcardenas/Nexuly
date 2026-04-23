/// Enums del dominio Nexuly.
///
/// Cada enum expone `value` (el string que se guarda en Firestore) y
/// un factory `fromValue` tolerante a nulos/valores desconocidos.
/// Esto evita perder datos si Firestore trae un valor que aún no manejamos.

// ---------------------------------------------------------------------------
// Usuarios
// ---------------------------------------------------------------------------

enum VerificationLevel {
  basic('basic'),
  verified('verified'),
  trusted('trusted');

  const VerificationLevel(this.value);
  final String value;

  static VerificationLevel fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => VerificationLevel.basic,
      );
}

enum TrustLabel {
  trusted('trusted'),
  standard('standard'),
  incidents('incidents');

  const TrustLabel(this.value);
  final String value;

  static TrustLabel fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => TrustLabel.standard,
      );
}

enum AuthProvider {
  email('email'),
  google('google'),
  apple('apple');

  const AuthProvider(this.value);
  final String value;

  static AuthProvider fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => AuthProvider.email,
      );
}

// ---------------------------------------------------------------------------
// Profesionales
// ---------------------------------------------------------------------------

enum ValidationStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  suspended('suspended');

  const ValidationStatus(this.value);
  final String value;

  static ValidationStatus fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => ValidationStatus.pending,
      );
}

enum CoverageType {
  radius('radius'),
  zones('zones');

  const CoverageType(this.value);
  final String value;

  static CoverageType fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => CoverageType.radius,
      );
}

enum DocumentType {
  idCard('id_card'),
  license('license'),
  certificate('certificate');

  const DocumentType(this.value);
  final String value;

  static DocumentType fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => DocumentType.idCard,
      );
}

enum DocumentStatus {
  pending('pending'),
  verified('verified'),
  rejected('rejected');

  const DocumentStatus(this.value);
  final String value;

  static DocumentStatus fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => DocumentStatus.pending,
      );
}

// ---------------------------------------------------------------------------
// Service Requests — máquina de estados
// ---------------------------------------------------------------------------

enum ServiceRequestStatus {
  created('CREATED'),
  pendingAssignment('PENDING_ASSIGNMENT'),
  pendingConfirmation('PENDING_CONFIRMATION'),
  confirmed('CONFIRMED'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  cancelled('CANCELLED'),
  noShow('NO_SHOW');

  const ServiceRequestStatus(this.value);
  final String value;

  static ServiceRequestStatus fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => ServiceRequestStatus.created,
      );

  /// Transiciones válidas desde este estado.
  /// Útil para validar en la UI antes de enviar un cambio.
  Set<ServiceRequestStatus> get allowedTransitions {
    switch (this) {
      case ServiceRequestStatus.created:
        return {
          ServiceRequestStatus.pendingAssignment,
          ServiceRequestStatus.pendingConfirmation,
          ServiceRequestStatus.cancelled,
        };
      case ServiceRequestStatus.pendingAssignment:
        return {
          ServiceRequestStatus.pendingConfirmation,
          ServiceRequestStatus.cancelled,
        };
      case ServiceRequestStatus.pendingConfirmation:
        return {
          ServiceRequestStatus.confirmed,
          ServiceRequestStatus.cancelled,
        };
      case ServiceRequestStatus.confirmed:
        return {
          ServiceRequestStatus.inProgress,
          ServiceRequestStatus.cancelled,
          ServiceRequestStatus.noShow,
        };
      case ServiceRequestStatus.inProgress:
        return {ServiceRequestStatus.completed};
      case ServiceRequestStatus.completed:
      case ServiceRequestStatus.cancelled:
      case ServiceRequestStatus.noShow:
        return <ServiceRequestStatus>{};
    }
  }

  bool get isTerminal => allowedTransitions.isEmpty;
}

enum RequestType {
  manual('manual'),
  open('open');

  const RequestType(this.value);
  final String value;

  static RequestType fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => RequestType.manual,
      );
}

enum ActorRole {
  user('user'),
  professional('professional'),
  system('system');

  const ActorRole(this.value);
  final String value;

  static ActorRole fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => ActorRole.system,
      );
}

// ---------------------------------------------------------------------------
// Notificaciones
// ---------------------------------------------------------------------------

enum NotificationType {
  requestCreated('request_created'),
  confirmed('confirmed'),
  rejected('rejected'),
  reminder('reminder'),
  newMessage('new_message'),
  statusChange('status_change');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => NotificationType.statusChange,
      );
}

enum NotificationChannel {
  push('push'),
  email('email'),
  sms('sms');

  const NotificationChannel(this.value);
  final String value;

  static NotificationChannel fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => NotificationChannel.push,
      );
}

enum RecipientRole {
  user('user'),
  professional('professional'),
  admin('admin');

  const RecipientRole(this.value);
  final String value;

  static RecipientRole fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => RecipientRole.user,
      );
}

// ---------------------------------------------------------------------------
// Admin actions
// ---------------------------------------------------------------------------

enum AdminActionType {
  approveProfessional('approve_professional'),
  rejectProfessional('reject_professional'),
  suspendUser('suspend_user'),
  resolveIncident('resolve_incident');

  const AdminActionType(this.value);
  final String value;

  static AdminActionType fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => AdminActionType.resolveIncident,
      );
}

enum AdminTargetType {
  user('user'),
  professional('professional'),
  request('request');

  const AdminTargetType(this.value);
  final String value;

  static AdminTargetType fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => AdminTargetType.user,
      );
}

// ---------------------------------------------------------------------------
// IA
// ---------------------------------------------------------------------------

enum AiFeedback {
  helpful('helpful'),
  notHelpful('not_helpful');

  const AiFeedback(this.value);
  final String value;

  static AiFeedback? fromValue(String? v) {
    if (v == null) return null;
    for (final e in values) {
      if (e.value == v) return e;
    }
    return null;
  }
}
