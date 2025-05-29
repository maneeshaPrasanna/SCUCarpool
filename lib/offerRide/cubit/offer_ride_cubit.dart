import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santa_clara/models/driver.dart';
import 'package:santa_clara/models/location.dart';
import 'package:santa_clara/models/ride.dart';
import 'package:santa_clara/models/user.dart';
import 'package:santa_clara/models/vehicle.dart';
import 'package:santa_clara/offerRide/cubit/offer_ride_state.dart';

class OfferRideCubit extends Cubit<OfferRideState> {
  final FirebaseFirestore _firestore;

  OfferRideCubit(this._firestore) : super(OfferRideInitial());

  Future<void> offerRide({
    required LocationModel pickupLocation,
    required LocationModel destinationLocation,
    required DateTime departureTime,
    required int seatsAvailable,
    required String description,
    required User user,
  }) async {
    emit(OfferRideLoading());

    try {
      print('Offering ride with the following details:');
      final vehicleDoc =
          await _firestore.collection('cars').doc(user.uid).get();

      if (!vehicleDoc.exists) {
        emit(OfferRideError('No vehicle found for user.'));
        return;
      }

      final vehicle = Vehicle.fromMap(vehicleDoc.data()!);

      // print('Driver object: ${driver.toJson()}');
      print('User object: ${user.toJson()}');
      print('Vehicle object: ${vehicle.toJson()}');
      print('Pickup Location object: ${pickupLocation.toJson()}');
      print('Destination Location object: ${destinationLocation.toJson()}');
      //print('Document Reference: ${docRef.id}');
      final docRef = _firestore.collection('rides').doc();

      final driver = Driver(
        user: user,
        rating: 4.8, // You can make this configurable later
        vehicle: vehicle,
      );
      //print('Ride object: ${ride.toJson()}');
      print('Driver object: ${driver.toJson()}');
      print('User object: ${user.toJson()}');
      print('Vehicle object: ${vehicle.toJson()}');
      print('Pickup Location object: ${pickupLocation.toJson()}');
      print('Destination Location object: ${destinationLocation.toJson()}');
      print('Document Reference: ${docRef.id}');

      final ride = Ride(
        id: docRef.id,
        pickupLocation: pickupLocation,
        destinationLocation: destinationLocation,
        departureTime: departureTime,
        seatsAvailable: seatsAvailable,
        description: description,
        driver: driver,
      );

      print('Ride object: ${ride.toJson()}');
      print('Driver object: ${driver.toJson()}');
      print('User object: ${user.toJson()}');
      print('Vehicle object: ${vehicle.toJson()}');
      print('Pickup Location object: ${pickupLocation.toJson()}');
      print('Destination Location object: ${destinationLocation.toJson()}');
      print('Document Reference: ${docRef.id}');
      await docRef.set(ride.toJson());

      emit(OfferRideSuccess());
    } catch (e) {
      emit(OfferRideError('Failed to offer ride: $e'));
    }
  }
}
