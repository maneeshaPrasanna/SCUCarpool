import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:santa_clara/models/ride.dart';
import 'package:santa_clara/ride_details/cubit/ride_details_state.dart';
import 'package:santa_clara/ride_details/cubit/ride_repository.dart';

class RideDetailsCubit extends Cubit<RideDetailsState> {
  final RideRepository _rideRepo;

  RideDetailsCubit(this._rideRepo, Ride ride)
      : super(RideDetailsState(ride: ride)) {
    _listenToMockDriverLocation();
  }

  void _listenToMockDriverLocation() {
    final pickup = state.ride.pickupLocation.coordinates;
    final mockStart = LatLng(
        pickup.latitude - 0.01, pickup.longitude - 0.01); // somewhere nearby

    _rideRepo
        .mockDriverLocationStream(mockStart, pickup)
        .listen((driverLatLng) {
      emit(state.copyWith(driverLocation: driverLatLng));
    });
  }
}
