import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_state.dart';
import 'package:khadem/features/mainScreen/home/presentation/bloc/home_event.dart' hide AuthEvent;

class HomeBloc extends Bloc<HomeEvent, AuthState> {
  HomeBloc() : super(AuthInitialState()) {
    
  // on<HomeEvent>((event, emit) async {
  //   await login(event, emit);
  // });

  // on<SignUpEvent>((event, emit) async {
  //   await signUp(event, emit);
  // });
  // }

  
  // String? specialization;
  // String imageUrl = '';

  // Future<void> signUp(SignUpEvent event, Emitter<HomeState> emit) async {
  //   emit(AuthLoadingState());
  //   final result = await AuthRepo.signUp(
  //     name: event.name,
  //     email: event.email,
  //     password: event.password,
  //     userType: event.userType,
  //   );
  //   result.fold(
  //     (error) {
  //       emit(AuthErrorState(error));
  //     },
  //     (data) {
  //       emit(AuthSuccessState(data));
  //     },
  //   );
  // }

  // Future<void> login(LoginEvent event, Emitter<HomeState> emit) async {
  //   emit(AuthLoadingState());
  //   var result = await AuthRepo.login(
  //     email: event.email,
  //     password: event.password,
  //   );
  //   result.fold(
  //     (error) {
  //       emit(AuthErrorState(error));
  //     },
  //     (data) {
  //       emit(AuthSuccessState(data));
  //     },
  //   );
  // }

  // updateServant(Emitter<AuthState> emit) async {
  //   emit(AuthLoadingState());
  //   var result = await AuthRepo.updateServantData(
  //     ServantModel(
  //       uid: SharedPref.getUserId(),
  //       bio: bioController.text,
  //       openHour: openHourController.text,
  //       closeHour: closeHourController.text,
  //       address: addressController.text,
  //       phone1: phone1Controller.text,
  //       phone2: phone2Controller.text,
  //       specialization: specialization,
  //       image: imageUrl,
  //     ),
  //   );
  //   result.fold(
  //     (error) {
  //       emit(AuthErrorState(error));
  //     },
  //     (data) {
  //       emit(ServantRegistrationSuccessState());
  //     },
  //   );
   }
}

// Auth (small DB) => id, name, email, password, phone, image
// Firestore (Big DB) => id, name, email, password, phone, image, openHours, closedHours, location
