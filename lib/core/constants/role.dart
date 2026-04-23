/// Rol del usuario en la plataforma.
///
/// Se define en la pantalla de selección de rol y determina en qué colección
/// Firestore se creará el documento (`users` o `professionals`) al hacer signup.
enum UserRole {
  patient('patient'),
  professional('professional');

  const UserRole(this.value);
  final String value;

  static UserRole fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => UserRole.patient,
      );

  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Paciente';
      case UserRole.professional:
        return 'Profesional';
    }
  }
}
