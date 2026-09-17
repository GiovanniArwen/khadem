import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/features/auth/data/repo/auth_repo.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_event.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialState()) {
    on<LoginEvent>((event, emit) async {
      await login(event, emit);
    });

    on<SignUpEvent>((event, emit) async {
      await signUp(event, emit);
    });
  }

  String? specialization;
  String imageUrl = '';

  Future<void> signUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    final result = await AuthRepo.signUp(
      name: event.name,
      email: event.email,
      password: event.password,
      isServant: event.isServant,
      isChurchAdmin: event.isChurchAdmin,
    );

    result.fold(
      (error) {
        emit(AuthErrorState(error));
      },
      (roles) {
        final user = FirebaseAuth.instance.currentUser;

        print('================ AUTH BLOC SIGNUP ================');
        print('FIREBASE USER: $user');
        print('FIREBASE UID: "${user?.uid}"');
        print('===================================================');

        emit(
          AuthSuccessState(
            isServant: roles.isServant,
            isChurchAdmin: roles.isChurchAdmin,
            uid: user?.uid ?? '',
          ),
        );
      },
    );
  }

  Future<void> login(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    final result = await AuthRepo.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (error) {
        emit(AuthErrorState(error));
      },
      (roles) {
        final user = FirebaseAuth.instance.currentUser;

        print('================ AUTH BLOC ================');
        print('FIREBASE USER: $user');
        print('FIREBASE UID: "${user?.uid}"');
        print('===========================================');

        emit(
          AuthSuccessState(
            isServant: roles.isServant,
            isChurchAdmin: roles.isChurchAdmin,
            uid: user?.uid ?? '',
          ),
        );
      },
    );
  }
}

// Auth (small DB) => id, name, email, password, phone, image
// Firestore (Big DB) => id, name, email, password, phone, image, openHours, closedHours, location
