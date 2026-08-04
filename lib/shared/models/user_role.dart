/// The two (or three, for staff) account kinds in Collabsy.
///
/// Mirrors the `role` check constraint on the `profiles` table.
enum UserRole {
  creator,
  brand,
  admin;

  static UserRole? fromDbValue(String? value) {
    return switch (value) {
      'creator' => UserRole.creator,
      'brand' => UserRole.brand,
      'admin' => UserRole.admin,
      _ => null,
    };
  }

  String toDbValue() => name;

  /// User-facing label matching the login/signup tab text.
  String get label => switch (this) {
    UserRole.creator => 'Creator',
    UserRole.brand => 'Brand / Agency',
    UserRole.admin => 'Admin',
  };
}
