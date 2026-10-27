import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/features/main_screen/servants/data/models/servant_model.dart';
import 'package:khadem/features/main_screen/servants/presentation/bloc/servant_states.dart';

import '../../data/repo/servant_repo.dart';
import 'servant_event.dart';

class ServantBloc extends Bloc<ServantEvent, ServantState> {
  final ServantRepo _repo = ServantRepo();

  List<ServantModel> _allServants = [];

  String _searchQuery = '';
  List<String> _selectedSpecializations = [];
  String? _selectedGovernorate;

  ServantBloc() : super(ServantInitialState()) {
    on<LoadServantsEvent>(_loadServants);
    on<SearchServantsEvent>(_searchServants);
    on<FilterServantsEvent>(_filterServants);
  }

  // =========================
  // Load
  // =========================

  Future<void> _loadServants(
    LoadServantsEvent event,
    Emitter<ServantState> emit,
  ) async {
    emit(ServantLoadingState());

    await emit.onEach<List<ServantModel>>(
      _repo.getApprovedServants(),
      onData: (servants) {
        final myUid = FirebaseAuth.instance.currentUser?.uid;

        _allServants = servants
            .where((servant) => servant.uid != myUid)
            .toList();

        _applyFilters(emit);
      },
      onError: (error, stackTrace) {
        emit(ServantErrorState('حدث خطأ أثناء تحميل الخدام'));
      },
    );
  }

  // =========================
  // Search
  // =========================

  void _searchServants(SearchServantsEvent event, Emitter<ServantState> emit) {
    _searchQuery = event.query.trim().toLowerCase();

    _applyFilters(emit);
  }

  // =========================
  // Filter
  // =========================

  void _filterServants(FilterServantsEvent event, Emitter<ServantState> emit) {
    _selectedSpecializations = event.specializations;
    _selectedGovernorate = event.governorate;

    _applyFilters(emit);
  }

  // =========================
  // Apply Everything
  // =========================

  void _applyFilters(Emitter<ServantState> emit) {
    final results = _allServants.where((servant) {
      // -------------------------
      // Search
      // -------------------------

      final searchMatch =
          _searchQuery.isEmpty ||
          servant.name?.toLowerCase().contains(_searchQuery) == true ||
          servant.specialization?.any(
                (specialization) =>
                    specialization.toLowerCase().contains(_searchQuery),
              ) ==
              true ||
          servant.governorate?.toLowerCase().contains(_searchQuery) == true ||
          servant.church?.toLowerCase().contains(_searchQuery) == true;

      // -------------------------
      // Specialization
      // -------------------------

      final specializationMatch =
          _selectedSpecializations.isEmpty ||
          _selectedSpecializations.any(
            (selected) => servant.specialization?.contains(selected) == true,
          );

      // -------------------------
      // Governorate
      // -------------------------

      final governorateMatch =
          _selectedGovernorate == null ||
          _selectedGovernorate!.isEmpty ||
          servant.governorate == _selectedGovernorate;

      return searchMatch && specializationMatch && governorateMatch;
    }).toList();

    emit(ServantLoadedState(results));
  }
}
