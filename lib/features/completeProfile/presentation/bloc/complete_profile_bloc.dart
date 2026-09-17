// lib/features/completeProfile/presentation/bloc/complete_profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repo/complete_profile_repo.dart';
import 'complete_profile_event.dart';
import 'complete_profile_state.dart';

class CompleteProfileBloc
    extends Bloc<CompleteProfileEvent, CompleteProfileState> {
  CompleteProfileBloc() : super(CompleteProfileInitialState()) {
    on<SaveCompleteProfileEvent>(_saveProfile);
  }

  Future<void> _saveProfile(
    SaveCompleteProfileEvent event,
    Emitter<CompleteProfileState> emit,
  ) async {
    emit(CompleteProfileLoadingState());

    try {
      await CompleteProfileRepo.saveProfile(
        uid: event.uid,
        isServant: event.isServant,
        isChurchAdmin: event.isChurchAdmin,
        name: event.name,
        email: event.email,
        imageFile: event.imageFile,
        phone1: event.phone1,
        phone2: event.phone2,
        age: event.age,
        governorate: event.governorate,
        church: event.church,
        bio: event.bio,
        specialization: event.specialization,
        openHour: event.openHour,
        closeHour: event.closeHour,
        meetingName: event.meetingName,
      );

      emit(CompleteProfileSuccessState());
    } catch (e) {
      emit(CompleteProfileErrorState('حدث خطأ أثناء حفظ البيانات'));
    }
  }
}
