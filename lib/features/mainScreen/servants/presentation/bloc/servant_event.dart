abstract class ServantEvent {}

class LoadServantsEvent extends ServantEvent {}

class SearchServantsEvent extends ServantEvent {
  final String query;

  SearchServantsEvent(this.query);
}

class FilterServantsEvent extends ServantEvent {
  final String? specialization;
  final String? governorate;
  final bool? isAvailable;

  FilterServantsEvent({
    this.specialization,
    this.governorate,
    this.isAvailable,
  });
}