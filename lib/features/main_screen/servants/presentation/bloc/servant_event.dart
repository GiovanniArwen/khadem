abstract class ServantEvent {}

class LoadServantsEvent extends ServantEvent {}

class SearchServantsEvent extends ServantEvent {
  final String query;

  SearchServantsEvent(this.query);
}

class FilterServantsEvent extends ServantEvent {
  final List<String> specializations;
  final String? governorate;

  FilterServantsEvent({
    this.specializations = const [],
    this.governorate,
  });
}

