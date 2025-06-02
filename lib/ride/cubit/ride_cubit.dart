import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santa_clara/models/location.dart';
import 'package:santa_clara/models/ride.dart';
import 'package:santa_clara/models/user.dart';
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
      await fetchRides(_pickup!, _destination!);
    }
  }

  Future<void> loadRides() async {
    if (_pickup != null && _destination != null) {
      await fetchRides(_pickup!, _destination!);
    }
  }

  Future<void> fetchRides(
      LocationModel pickup, LocationModel destination) async {
    emit(RideLoading());
    try {
      final now = DateTime.now().toIso8601String();
      final querySnapshot = await firestore
          .collection('rides')
          .where('pickupLocation.address', isEqualTo: pickup.address)
          .where('destinationLocation.address', isEqualTo: destination.address)
          .where('departureTime', isGreaterThan: now)
          .where('seatsAvailable', isGreaterThan: 0)
          .orderBy('createdAt', descending: true)
          .get(const GetOptions(source: Source.server));

      final rides = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Ride.fromMap(doc.id, data);
      }).toList();

      emit(RideLoaded(rides));
    } catch (e) {
      emit(RideError('Failed to fetch rides: $e'));
    }
  }

  void selectRide(Ride ride) {
    emit(RideSelected(ride));
  }

  Future<void> joinRide(String rideId, User user) async {
    try {
      // await firestore.runTransaction((transaction) async {
      //   final docRef = firestore.collection('rides').doc(rideId);
      //   final snapshot = await transaction.get(docRef);

      //   if (!snapshot.exists) {
      //     throw Exception('Ride does not exist.');
      //   }

      //   final data = snapshot.data();
      //   if (data == null || !data.containsKey('seatsAvailable')) {
      //     throw Exception('Invalid ride data.');
      //   }

      //   final seatsAvailable = data['seatsAvailable'] as int;

      //   if (seatsAvailable <= 0) {
      //     throw Exception('No seats available.');
      //   }

      //   transaction.update(docRef, {
      //     'seatsAvailable': seatsAvailable - 1,
      //     // You can also update joined users here if needed
      //     // 'joinedUsers': FieldValue.arrayUnion(['currentUserId']),
      //   });
      // });
// ...existing code...
      await firestore.collection('rides').doc(rideId).update({
        'joinedUsers': FieldValue.arrayUnion([
          {
            'uid': user.uid,
            'name': user.name,
            // Optionally add phone/email, etc.
          }
        ]),
        'seatsAvailable': FieldValue.increment(-1)
      });
// ...existing code...

      emit(RideJoined(rideId));
    } catch (e) {
      emit(RideError('Failed to join ride: $e'));
    }
  }

  Future<void> loadMyRidesSplit(String userId) async {
    emit(RideLoading());
    try {
      final querySnapshot = await firestore
          .collection('rides')
          .where('driver.user.uid', isEqualTo: userId)
          .get();

      final now = DateTime.now();
      final allRides = querySnapshot.docs
          .map((doc) => Ride.fromMap(doc.id, doc.data()))
          .toList();

      final upcoming = allRides
          .where((r) => r.departureTime.isAfter(now))
          .toList()
        ..sort((a, b) => (b.createdAt ?? DateTime(1970))
            .compareTo(a.createdAt ?? DateTime(1970)));

      final past =
          allRides.where((r) => r.departureTime.isBefore(now)).toList();

      emit(RideSplitLoaded(upcoming: upcoming, past: past));
    } catch (e) {
      emit(RideError('Failed to load rides: $e'));
    }
  }

  void clearRideSearchState() {
    _pickup = null;
    _destination = null;
    emit(RideInitial());
  }
}
