abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class SignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final bool isServant;
  final bool isChurchAdmin;

  SignUpEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.isServant,
    required this.isChurchAdmin,
  });
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  ForgotPasswordEvent({required this.email});
}
