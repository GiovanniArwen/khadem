
import 'package:khadem/features/auth/data/models/user_type_enum.dart';

class AuthEvent {}

class HomeEvent extends AuthEvent {
  final String email;
  final String password;

  HomeEvent({
    required this.email,
    required this.password,
  });
}



