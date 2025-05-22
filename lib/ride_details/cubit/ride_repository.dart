import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRepository {
  /// Simulates a moving driver from start to pickup
  Stream<LatLng> mockDriverLocationStream(LatLng start, LatLng end) async* {
    const steps = 20;
    const delay = Duration(seconds: 1);

    for (int i = 0; i <= steps; i++) {
      final lat =
          start.latitude + (end.latitude - start.latitude) * (i / steps);
      final lng =
          start.longitude + (end.longitude - start.longitude) * (i / steps);
      yield LatLng(lat, lng);
      await Future.delayed(delay);
    }
  }
}
// This is a mock implementation. In a real app, you would connect to a backend service
