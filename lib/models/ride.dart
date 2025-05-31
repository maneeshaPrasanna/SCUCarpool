import 'package:cloud_firestore/cloud_firestore.dart';
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
  final DateTime? createdAt;

  Ride({
    required this.id,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.departureTime,
    required this.seatsAvailable,
    required this.driver,
    required this.description,
    this.createdAt,
  });

  Map<String, dynamic> toMap({bool includeServerTimestamp = false}) {
    return {
      'pickupLocation': pickupLocation.toMap(),
      'destinationLocation': destinationLocation.toMap(),
      'departureTime': Timestamp.fromDate(departureTime),
      'seatsAvailable': seatsAvailable,
      'driver': driver.toMap(),
      'description': description,
      if (includeServerTimestamp) 'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static Ride fromMap(String id, Map<String, dynamic> map) {
    return Ride(
      id: id,
      pickupLocation: LocationModel.fromMap(map['pickupLocation']),
      destinationLocation: LocationModel.fromMap(map['destinationLocation']),
      departureTime: map['departureTime'] is Timestamp
          ? (map['departureTime'] as Timestamp).toDate()
          : DateTime.parse(map['departureTime']),
      seatsAvailable: map['seatsAvailable'],
      driver: Driver.fromMap(map['driver']),
      description: map['description'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : map['createdAt'] != null
              ? DateTime.tryParse(map['createdAt'])
              : null,
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
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
