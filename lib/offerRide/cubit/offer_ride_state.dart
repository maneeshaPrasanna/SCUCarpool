abstract class OfferRideState {}

class OfferRideInitial extends OfferRideState {}

class OfferRideLoading extends OfferRideState {}

class OfferRideSuccess extends OfferRideState {}

class OfferRideError extends OfferRideState {
  final String message;
  OfferRideError(this.message);
}
