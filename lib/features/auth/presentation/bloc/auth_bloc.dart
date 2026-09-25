import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/features/auth/data/repo/auth_repo.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_event.dart';
import 'package:khadem/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialState()) {
    on<LoginEvent>(_onLogin);
    on<SignUpEvent>(_onSignUp);
    on<ForgotPasswordEvent>(_onForgotPassword);
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
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
        emit(
          AuthSuccessState(
            uid: roles.uid,
            isServant: roles.isServant,
            isChurchAdmin: roles.isChurchAdmin,
          ),
        );
      },
    );
  }

  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
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
        emit(
          AuthSuccessState(
            uid: roles.uid,
            isServant: roles.isServant,
            isChurchAdmin: roles.isChurchAdmin,
          ),
        );
      },
    );
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    final result = await AuthRepo.forgotPassword(
      email: event.email,
      languageCode: 'ar',
    );

    result.fold(
      (error) {
        emit(AuthErrorState(error));
      },
      (message) {
        emit(ForgotPasswordSuccessState(message));
      },
    );
  }
}