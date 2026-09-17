class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final bool isServant;
  final bool isChurchAdmin;
  final String uid;

  AuthSuccessState({
    required this.isServant,
    required this.isChurchAdmin,
    required this.uid,
  });
}

class AuthErrorState extends AuthState {
  final String message;

  AuthErrorState(this.message);
}
