import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final String name;
  final String address;
  final LatLng coordinates;
  final String? placeId; // optional, useful if using Google Places API

  LocationModel({
    required this.name,
    required this.address,
    required this.coordinates,
    this.placeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'placeId': placeId,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      name: map['name'],
      address: map['address'],
      coordinates: LatLng(map['latitude'], map['longitude']),
      placeId: map['placeId'],
    );
  }
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'],
      address: json['address'],
      coordinates: LatLng(
        json['coordinates']['lat'],
        json['coordinates']['lng'],
      ),
      placeId: json['placeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'coordinates': {
        'lat': coordinates.latitude,
        'lng': coordinates.longitude,
      },
      'placeId': placeId,
    };
  }
}
