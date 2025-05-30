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

  // factory LocationModel.fromMap(Map<String, dynamic> map) {
  //   final coordinatesMap = map['coordinates'];
  //   print("coordinatesMap: $coordinatesMap");
  //   print("name: ${map['name']}");
  //   print("address: ${map['address']}");
  //   print("latitude: ${map['latitude']}");
  //   print("longitude: ${map['longitude']}");
  //   if (map['latitude'] == null || map['longitude'] == null) {
  //     throw const FormatException(
  //         "Invalid coordinates: latitude or longitude is null");
  //   }

  //   return LocationModel(
  //     name: map['name'],
  //     address: map['address'],
  //     coordinates: LatLng(map['latitude'], map['longitude']),
  //     placeId: map['placeId'],
  //   );
  // }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    final coordinatesMap = map['coordinates'];
    print("coordinatesMap: $coordinatesMap");
    print("name: ${map['name']}");
    print("address: ${map['address']}");
    print("latitude: ${map['latitude']}");
    if (coordinatesMap == null ||
        coordinatesMap['lat'] == null ||
        coordinatesMap['lng'] == null) {
      print(" coordinates is null in: $map");
      throw const FormatException("Invalid coordinates: lat or lng is null");
    }

    return LocationModel(
      name: map['name'],
      address: map['address'],
      coordinates: LatLng(
        (coordinatesMap['lat'] as num).toDouble(),
        (coordinatesMap['lng'] as num).toDouble(),
      ),
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
