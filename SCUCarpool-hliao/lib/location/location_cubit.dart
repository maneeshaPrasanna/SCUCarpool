import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

import 'package:santa_clara/constant/constant.dart';
import 'package:santa_clara/location/location_state.dart';

class LocationAutocompleteCubit extends Cubit<LocationAutocompleteState> {
  final FlutterGooglePlacesSdk _places =
      FlutterGooglePlacesSdk(AppConstants.kGoogleApiKey);
  Timer? _debounce;

  LocationAutocompleteCubit() : super(LocationInitial());

  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        emit(LocationInitial());
        return;
      }

      emit(LocationLoading());
      try {
        final response = await _places.findAutocompletePredictions(query);
        // No status check needed

        emit(LocationLoaded(response.predictions));
      } catch (e) {
        emit(LocationError('Error: $e'));
      }
    });

    @override
    Future<void> close() {
      _debounce?.cancel();
      return super.close();
    }
  }
}
