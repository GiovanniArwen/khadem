abstract class CompleteProfileState {}

class CompleteProfileInitialState extends CompleteProfileState {}

class CompleteProfileLoadingState extends CompleteProfileState {}

class CompleteProfileSuccessState extends CompleteProfileState {}

class CompleteProfileErrorState extends CompleteProfileState {
  final String message;

  CompleteProfileErrorState(this.message);
}