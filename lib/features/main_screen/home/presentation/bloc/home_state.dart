
import 'package:khadem/features/auth/data/models/user_type_enum.dart';

class HomeState {}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeSuccessState extends HomeState {
  final UserTypeEnum userType;

  HomeSuccessState(this.userType);
}
// class ServantRegistrationSuccessState extends AuthState {}

class HomeErrorState extends HomeState {
  final String message;
  HomeErrorState(this.message);
}

