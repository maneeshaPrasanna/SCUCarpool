import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
//import 'package:google_maps_webservice/places.dart';
import 'package:santa_clara/constant/constant.dart';
import 'package:santa_clara/location/location_cubit.dart';
import 'package:santa_clara/location/location_helper.dart';
import 'package:santa_clara/models/location.dart';

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
