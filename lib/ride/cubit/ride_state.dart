import 'package:equatable/equatable.dart';
import 'package:santa_clara/models/ride.dart';

abstract class RideState extends Equatable {
  const RideState();

  @override
  List<Object> get props => [];
}

class RideInitial extends RideState {}

class RideLoading extends RideState {}

class RideLoaded extends RideState {
  final List<Ride> rides;

  const RideLoaded(this.rides);

  @override
  List<Object> get props => [rides];
}

class RideSelected extends RideState {
  final Ride selectedRide;

  const RideSelected(this.selectedRide);

  @override
  List<Object> get props => [selectedRide];
}

class RideJoined extends RideState {
  final String rideId;

  const RideJoined(this.rideId);

  @override
  List<Object> get props => [rideId];
}

class RideError extends RideState {
  final String message;

  const RideError(this.message);

  @override
  List<Object> get props => [message];
}
