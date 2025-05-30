import 'package:santa_clara/models/user.dart';
import 'package:santa_clara/models/vehicle.dart';

class Driver {
  final User user;
  final double rating;
  final Vehicle vehicle;

  Driver({
    required this.user,
    required this.rating,
    required this.vehicle,
  });

  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      'rating': rating,
      'vehicle': vehicle.toMap(),
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      user: User.fromMap(map['user']),
      rating: (map['rating'] as num).toDouble(),
      vehicle: Vehicle.fromMap(map['vehicle']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'rating': rating,
      'vehicle': vehicle.toJson(),
    };
  }
}

//import 'package:google_maps_flutter/google_maps_flutter.dart';

// class Driver {
//   final String id;
//   final String name;
//   final String email;
//   final String phone;
//   final String vehicleModel;
//   final String vehicleNumber;
//   final int seatsAvailable;
//   final LatLng currentLocation;
//   final String destination;
//   final DateTime departureTime;

//   Driver({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.vehicleModel,
//     required this.vehicleNumber,
//     required this.seatsAvailable,
//     required this.currentLocation,
//     required this.destination,
//     required this.departureTime,
//   });

//   factory Driver.fromJson(Map<String, dynamic> json) {
//     return Driver(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       phone: json['phone'],
//       vehicleModel: json['vehicleModel'],
//       vehicleNumber: json['vehicleNumber'],
//       seatsAvailable: json['seatsAvailable'],
//       currentLocation: LatLng(
//         json['currentLocation']['lat'],
//         json['currentLocation']['lng'],
//       ),
//       destination: json['destination'],
//       departureTime: DateTime.parse(json['departureTime']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'vehicleModel': vehicleModel,
//       'vehicleNumber': vehicleNumber,
//       'seatsAvailable': seatsAvailable,
//       'currentLocation': {
//         'lat': currentLocation.latitude,
//         'lng': currentLocation.longitude,
//       },
//       'destination': destination,
//       'departureTime': departureTime.toIso8601String(),
//     };
//   }
// }
