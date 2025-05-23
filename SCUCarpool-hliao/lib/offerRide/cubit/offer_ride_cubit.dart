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
    required Vehicle vehicle,
  }) async {
    emit(OfferRideLoading());

    try {
      final docRef = _firestore.collection('rides').doc();

      final driver = Driver(
        user: user,
        rating: 4.8, // You can make this configurable later
        vehicle: vehicle,
      );

      final ride = Ride(
        id: docRef.id,
        pickupLocation: pickupLocation,
        destinationLocation: destinationLocation,
        departureTime: departureTime,
        seatsAvailable: seatsAvailable,
        description: description,
        driver: driver,
      );

      await docRef.set(ride.toJson());
      emit(OfferRideSuccess());
    } catch (e) {
      emit(OfferRideError('Failed to offer ride: $e'));
    }
  }
}
