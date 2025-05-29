import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:santa_clara/models/driver.dart';
import 'package:santa_clara/models/location.dart';
import 'package:santa_clara/models/ride.dart';
import 'package:santa_clara/models/user.dart';
import 'package:santa_clara/models/vehicle.dart';

Future<void> seedSampleRides() async {
  final firestore = FirebaseFirestore.instance;

  final sampleRides = [
    Ride(
      id: '',
      pickupLocation: LocationModel(
        name: 'Santa Clara University',
        address: '500 El Camino Real, Santa Clara, CA',
        coordinates: const LatLng(37.3496, -121.9389),
        placeId: 'scu_place_id',
      ),
      destinationLocation: LocationModel(
        name: 'San Jose',
        address: 'San Jose, CA',
        coordinates: const LatLng(37.3382, -121.8863),
        placeId: 'sj_place_id',
      ),
      departureTime: DateTime.now().add(const Duration(hours: 2)),
      seatsAvailable: 3,
      description:
          'Pickup location Santa Clara University, waiting for 10 mins',
      driver: Driver(
          user: User(
            uid: 'xyz',
            name: 'Alice Johnson',
            email: 'AliceJohnson@gmail.com',
            imageUrl: 'assets/aliceJohnson.jpg',
            phoneNumber: '1234567',
            emailVerified: false,
            createdAt: 'xyz',
          ),
          rating: 4.8,
          vehicle: Vehicle(
            maker: 'Tesla',
            model: 'Model 3',
            plate: '1234',
            carColor: 'Red',
          )),
    ),
  ];

  for (final ride in sampleRides) {
    final docRef = await firestore.collection('rides').add(ride.toMap());
    print('Ride added with ID: ${docRef.id}');
  }
}
