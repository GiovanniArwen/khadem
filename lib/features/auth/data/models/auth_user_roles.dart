class AuthUserRoles {
  final String uid;
  final bool isServant;
  final bool isChurchAdmin;

  const AuthUserRoles({
    required this.uid,
    required this.isServant,
    required this.isChurchAdmin,
  });
}
