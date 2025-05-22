// import 'package:santa_clara/model/driver.dart';
// import 'package:santa_clara/model/location.dart';

// class Ride {
//   final LocationModel pickupLocation;
//   final LocationModel destinationLocation;
//   final Driver driver;
//   final int seatsAvailable;
//   final DateTime dateTime;
//   final String note;

//   Ride({
//     required this.pickupLocation,
//     required this.destinationLocation,
//     required this.driver,
//     required this.seatsAvailable,
//     required this.dateTime,
//     required this.note,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'pickupLocation': pickupLocation.toMap(),
//       'destinationLocation': destinationLocation.toMap(),
//       'driver': driver.toMap(),
//       'seatsAvailable': seatsAvailable,
//       'dateTime': dateTime.toIso8601String(),
//       'note': note,
//     };
//   }

//   factory Ride.fromMap(Map<String, dynamic> map) {
//     return Ride(
//       pickupLocation: LocationModel.fromMap(map['pickupLocation']),
//       destinationLocation: LocationModel.fromMap(map['destinationLocation']),
//       driver: Driver.fromMap(map['driver']),
//       seatsAvailable: map['seatsAvailable'],
//       dateTime: DateTime.parse(map['dateTime']),
//       note: map['note'],
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:santa_clara/models/driver.dart';
import 'package:santa_clara/models/location.dart';

class Ride {
  final String id;
  final LocationModel pickupLocation;
  final LocationModel destinationLocation;
  final DateTime departureTime;
  final int seatsAvailable;
  final Driver driver;
  final String description;

  Ride({
    required this.id,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.departureTime,
    required this.seatsAvailable,
    required this.driver,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'pickupLocation': pickupLocation.toMap(),
      'destinationLocation': destinationLocation.toMap(),
      'departureTime': Timestamp.fromDate(departureTime),
      'seatsAvailable': seatsAvailable,
      'driver': driver.toMap(),
      'description': description,
    };
  }

  static Ride fromMap(String id, Map<String, dynamic> map) {
    return Ride(
      id: id,
      pickupLocation: LocationModel.fromMap(map['pickupLocation']),
      destinationLocation: LocationModel.fromMap(map['destinationLocation']),
      departureTime: (map['departureTime'] as Timestamp).toDate(),
      seatsAvailable: map['seatsAvailable'],
      driver: Driver.fromMap(map['driver']),
      description: map['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickupLocation': pickupLocation.toJson(),
      'destinationLocation': destinationLocation.toJson(),
      'departureTime': departureTime.toIso8601String(),
      'seatsAvailable': seatsAvailable,
      'description': description,
      'driver': driver.toJson(),
    };
  }
}
