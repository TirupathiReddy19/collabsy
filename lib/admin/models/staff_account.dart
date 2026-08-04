/// One `staffAccounts` document — an admin-portal login with access
/// restricted to whichever sidebar sections it's been granted, created via
/// Role Management. `permissions` is keyed by the same `AdminNavItem.path`
/// values used to build the sidebar (see admin_nav_item.dart), e.g.
/// `{'/support': true}`. `/roles` is never a valid key — Role Management
/// itself is always super-admin-only, never delegated.
typedef StaffAccount = ({
  String uid,
  String email,
  String roleName,
  Map<String, bool> permissions,
  bool active,
  DateTime? createdAt,
});
