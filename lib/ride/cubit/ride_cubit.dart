import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santa_clara/models/location.dart';
import 'package:santa_clara/models/ride.dart';
import 'package:santa_clara/ride/cubit/ride_state.dart';

class RideCubit extends Cubit<RideState> {
  final FirebaseFirestore firestore;

  RideCubit({required this.firestore}) : super(RideInitial());

  LocationModel? _pickup;
  LocationModel? _destination;

  void setPickup(LocationModel location) {
    _pickup = location;
    _tryFetchRides();
  }

  void setDestination(LocationModel location) {
    _destination = location;
    _tryFetchRides();
  }

  Future<void> _tryFetchRides() async {
    if (_pickup != null && _destination != null) {
      print('nefore%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
      await fetchRides(_pickup!, _destination!);
      print('after%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    }
  }

  Future<void> fetchRides(
      LocationModel pickup, LocationModel destination) async {
    emit(RideLoading());
    print('ohkkkll!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    try {
      final querySnapshot = await firestore
          .collection('rides')
          .where('pickupLocation.address', isEqualTo: pickup.address)
          .where('destinationLocation.address', isEqualTo: destination.address)
          .get();

      final rides = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Ride.fromMap(
            doc.id, data); // assuming fromMap accepts Map and docId
      }).toList();

      emit(RideLoaded(rides));
    } catch (e) {
      emit(RideError('Failed to fetch rides: $e'));
    }
  }

  void selectRide(Ride ride) {
    emit(RideSelected(ride));
  }

  Future<void> joinRide(String rideId) async {
    try {
      // Update logic as per your schema (e.g., add user to `joinedUsers` array)
      await firestore.collection('rides').doc(rideId).update({
        // Example: Add user ID to a "joinedUsers" array
        // 'joinedUsers': FieldValue.arrayUnion(['currentUserId']),
      });

      emit(RideJoined(rideId));
    } catch (e) {
      emit(RideError('Failed to join ride: $e'));
    }
  }
}
