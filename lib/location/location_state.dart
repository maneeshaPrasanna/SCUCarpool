
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
//import 'package:google_maps_webservice/places.dart';

// Cubit State
abstract class LocationAutocompleteState {}

class LocationInitial extends LocationAutocompleteState {}

class LocationLoading extends LocationAutocompleteState {}

class LocationLoaded extends LocationAutocompleteState {
  final List<AutocompletePrediction> predictions;
  LocationLoaded(this.predictions);
}

class LocationError extends LocationAutocompleteState {
  final String message;
  LocationError(this.message);
}
