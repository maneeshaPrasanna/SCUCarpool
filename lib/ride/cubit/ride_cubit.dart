import 'package:firebase_auth/firebase_auth.dart' as modelUser;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santa_clara/blocs/authentication/bloc/authentication_bloc.dart';
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
      final userId = modelUser.FirebaseAuth.instance.currentUser?.uid;

      final rides = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Ride.fromMapWithUser(doc.id, data, userId!);
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
      final rideDoc = await firestore.collection('rides').doc(rideId).get();
      final rideData = rideDoc.data();
      if (rideData == null) throw Exception("Ride not found");

      final joinedUsers =
          List<Map<String, dynamic>>.from(rideData['joinedUsers'] ?? []);

      // Check if user already joined
      final alreadyJoined = joinedUsers.any((u) => u['uid'] == user.uid);
      if (alreadyJoined) {
        return;
      }

      await firestore.collection('rides').doc(rideId).update({
        'joinedUsers': FieldValue.arrayUnion([
          {
            'uid': user.uid,
            'name': user.name,
          }
        ]),
        'seatsAvailable': FieldValue.increment(-1),
      });

      // await FirebaseFirestore.instance.collection('rideHistory').add({
      //   'userId': user.uid,
      //   'rideId': rideId,
      // });

// ...existing code...

      emit(RideJoined(rideId));
    } catch (e) {
      emit(RideError('Failed to join ride: $e'));
    }
  }

 Future<void> loadMyRidesSplit(String userId) async {
  emit(RideLoading());
  try {
    final now = DateTime.now();

    // 1. 用户是司机的 rides
    final driverQuerySnapshot = await firestore
        .collection('rides')
        .where('driver.user.uid', isEqualTo: userId)
        .get();

    final driverRides = driverQuerySnapshot.docs
        .map((doc) => Ride.fromMapWithUser(doc.id, doc.data(), userId))
        .toList();

    // 2. 用户是乘客的 rides（先加载所有包含 uid 的，再筛选）
    final passengerQuerySnapshot = await firestore
        .collection('rides')
        .where('joinedUsers', isNotEqualTo: null) // 过滤掉没有该字段的文档
        .get();

    final passengerRidesRaw = passengerQuerySnapshot.docs
        .map((doc) => Ride.fromMapWithUser(doc.id, doc.data(), userId))
        .where((ride) => ride.hasJoined)
        .toList();

    // 去重合并（可选：避免司机和乘客重复）
    final allRides = {
      for (var r in [...driverRides, ...passengerRidesRaw]) r.id: r
    }.values.toList();

    final upcoming = allRides
        .where((r) => r.departureTime.isAfter(now))
        .toList()
      ..sort((a, b) => (b.createdAt ?? DateTime(1970))
          .compareTo(a.createdAt ?? DateTime(1970)));

    final past = allRides.where((r) => r.departureTime.isBefore(now)).toList();

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
