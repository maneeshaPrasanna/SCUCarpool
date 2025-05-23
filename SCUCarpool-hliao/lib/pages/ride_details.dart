import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:santa_clara/models/ride.dart';
import 'package:santa_clara/ride_details/cubit/ride_details_cubit.dart';
import 'package:santa_clara/ride_details/cubit/ride_details_state.dart';
import 'package:santa_clara/ride_details/cubit/ride_repository.dart'; // <-- import this
import 'package:santa_clara/widgets/driver_card.dart';

class RideDetailsScreen extends StatelessWidget {
  final Ride ride;

  const RideDetailsScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final rideRepo = RideRepository(); // ✅ create repository instance here

    return BlocProvider(
      create: (_) => RideDetailsCubit(rideRepo, ride),
      child: const _RideDetailsContent(),
    );
  }
}

class _RideDetailsContent extends StatefulWidget {
  const _RideDetailsContent();

  @override
  State<_RideDetailsContent> createState() => _RideDetailsContentState();
}

class _RideDetailsContentState extends State<_RideDetailsContent> {
  int _selectedIndex = 0;

  void _onNavBarTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final ride = context.read<RideDetailsCubit>().state.ride;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF811E2D),
        title: const Text('Ride Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<RideDetailsCubit, RideDetailsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: ride.pickupLocation.coordinates,
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                          markerId: const MarkerId('pickup'),
                          position: ride.pickupLocation.coordinates),
                      Marker(
                          markerId: const MarkerId('destination'),
                          position: ride.destinationLocation.coordinates),
                      if (state.driverLocation != null)
                        Marker(
                            markerId: const MarkerId('driver'),
                            position: state.driverLocation!,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueBlue)),
                    },
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: [
                          ride.pickupLocation.coordinates,
                          ride.destinationLocation.coordinates
                        ],
                        width: 5,
                      )
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DriverCard(driver: ride.driver),
                      const SizedBox(height: 16),
                      Text('Seats Available: ${ride.seatsAvailable}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Departure: '
                          '${ride.departureTime.toLocal().toString().split('.').first}'),
                      const SizedBox(height: 8),
                      if (ride.description.isNotEmpty) ...[
                        const Text('Notes:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(ride.description),
                      ],
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: () {
                          // Open chat or request join
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF811E2D)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Text('Chat with Driver',
                              style: TextStyle(color: Color(0xFF811E2D))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
