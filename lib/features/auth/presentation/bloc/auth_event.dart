
import 'package:khadem/features/auth/data/models/user_type_enum.dart';

class AuthEvent {}

class LoginEvent extends AuthEvent {
  final UserTypeEnum userType;

  LoginEvent({required this.userType});
}

class SignUpEvent extends AuthEvent {
  final UserTypeEnum userType;

  SignUpEvent({required this.userType});
}

class ServantRegistrationEvent extends AuthEvent {}
