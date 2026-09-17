import 'package:khadem/features/mainScreen/servants/data/models/servant_model.dart';

abstract class ServantState {}

class ServantInitialState extends ServantState {}

class ServantLoadingState extends ServantState {}

class ServantLoadedState extends ServantState {
  final List<ServantModel> servants;

  ServantLoadedState(this.servants);
}

class ServantErrorState extends ServantState {
  final String message;

  ServantErrorState(this.message);
}