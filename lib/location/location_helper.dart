import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:santa_clara/constant/constant.dart';
import 'package:santa_clara/models/location.dart';

final _places = places.FlutterGooglePlacesSdk(AppConstants.kGoogleApiKey);

Future<LocationModel?> getPlaceDetailFromPrediction(
    places.AutocompletePrediction prediction) async {
  final response = await _places.fetchPlace(
    prediction.placeId,
    fields: [
      places.PlaceField.Name,
      places.PlaceField.Address,
      places.PlaceField.Location,
    ],
  );

  final place = response.place;

  final latLng = place?.latLng;
  if (latLng == null) return null;

  final coordinates = LatLng(latLng.lat, latLng.lng);

  return LocationModel(
    name: place?.name ?? '',
    address: place?.address ?? '',
    coordinates: coordinates,
  );
}
