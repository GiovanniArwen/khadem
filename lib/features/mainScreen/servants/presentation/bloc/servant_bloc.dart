import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/features/mainScreen/servants/data/models/servant_model.dart';
import 'package:khadem/features/mainScreen/servants/presentation/bloc/servant_states.dart';

import '../../data/repo/servant_repo.dart';
import 'servant_event.dart';

class ServantBloc extends Bloc<ServantEvent, ServantState> {
  final ServantRepo _repo = ServantRepo();

  List<ServantModel> _allServants = [];

  ServantBloc() : super(ServantInitialState()) {
    on<LoadServantsEvent>(_loadServants);
    on<SearchServantsEvent>(_searchServants);
    on<FilterServantsEvent>(_filterServants);
  }

  Future<void> _loadServants(
    LoadServantsEvent event,
    Emitter<ServantState> emit,
  ) async {
    emit(ServantLoadingState());

    // emit.onEach بيقفل الـ stream لوحده لما الـ bloc يتقفل،
    // وبيخلّي الـ emit يشتغل بأمان جوه الـ stream (بدل listen العادي)
    await emit.onEach<List<ServantModel>>(
      _repo.getApprovedServants(),
      onData: (servants) {
        // حسابي أنا مايظهرش في قايمة الخدام
        final myUid = FirebaseAuth.instance.currentUser?.uid;

        _allServants = servants
            .where((servant) => servant.uid != myUid)
            .toList();

        emit(ServantLoadedState(_allServants));
      },
      onError: (error, stackTrace) {
        emit(ServantErrorState('حدث خطأ أثناء تحميل الخدام'));
      },
    );
  }

  void _searchServants(SearchServantsEvent event, Emitter<ServantState> emit) {
    final query = event.query.trim().toLowerCase();

    if (query.isEmpty) {
      emit(ServantLoadedState(_allServants));
      return;
    }

    final results = _allServants.where((servant) {
      return servant.name?.toLowerCase().contains(query) == true ||
          servant.specialization?.toLowerCase().contains(query) == true ||
          servant.governorate?.toLowerCase().contains(query) == true ||
          servant.church?.toLowerCase().contains(query) == true;
    }).toList();

    emit(ServantLoadedState(results));
  }

  void _filterServants(FilterServantsEvent event, Emitter<ServantState> emit) {
    final results = _allServants.where((servant) {
      final specializationMatch =
          event.specialization == null ||
          event.specialization!.isEmpty ||
          servant.specialization == event.specialization;

      final governorateMatch =
          event.governorate == null ||
          event.governorate!.isEmpty ||
          servant.governorate == event.governorate;

      return specializationMatch && governorateMatch;
    }).toList();

    emit(ServantLoadedState(results));
  }
}