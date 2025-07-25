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
  final DateTime? createdAt;
  final bool hasJoined;

  Ride({
    required this.id,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.departureTime,
    required this.seatsAvailable,
    required this.driver,
    required this.description,
    this.createdAt,
    this.hasJoined = false,
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
    print('Ride user image URL: ${map['driver']?['user']?['imageUrl']}');

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

  static Ride fromMapWithUser(
      String id, Map<String, dynamic> map, String currentUserId) {
    final joinedUsers = map['joinedUsers'] as List<dynamic>? ?? [];
    final alreadyJoined =
        joinedUsers.any((user) => user['uid'] == currentUserId);

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
      hasJoined: alreadyJoined, // <-- new flag
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
