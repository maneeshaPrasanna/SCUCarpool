import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:santa_clara/models/ride.dart';

class RideDetailsState extends Equatable {
  final Ride ride;
  final LatLng? driverLocation;
  final double? driverDistanceMeters;
  final bool isLoading;

  const RideDetailsState({
    required this.ride,
    this.driverLocation,
    this.driverDistanceMeters,
    this.isLoading = false,
  });

  RideDetailsState copyWith({
    Ride? ride,
    LatLng? driverLocation,
    double? driverDistanceMeters,
    bool? isLoading,
  }) {
    return RideDetailsState(
      ride: ride ?? this.ride,
      driverLocation: driverLocation ?? this.driverLocation,
      driverDistanceMeters: driverDistanceMeters ?? this.driverDistanceMeters,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props =>
      [ride, driverLocation, driverDistanceMeters, isLoading];
}
