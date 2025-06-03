import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:santa_clara/models/ride.dart';
import 'package:santa_clara/widgets/driver_card.dart';
import 'package:santa_clara/constant/constant.dart';

class RideDetailsScreen extends StatefulWidget {
  final Ride ride;

  const RideDetailsScreen({super.key, required this.ride});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  late GoogleMapController mapController;
  StreamSubscription<Position>? positionStreamSubscription;
  LocationPermission? permission;
  LatLng? _currentUserLocation;
  bool _locationReady = false;

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 RideDetailsScreen initState for ride: ${widget.ride.id}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocationTracking();
    });
  }

  Future<void> _initializeLocationTracking() async {
    permission = await Geolocator.checkPermission();

    if (!_hasPermission()) {
      permission = await Geolocator.requestPermission();
      if (!_hasPermission()) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Location Permission Denied'),
              content: const Text(
                'This feature needs location access. Please allow location permissions to continue.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }
    }

    setState(() => _locationReady = true);

    try {
      positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      ).listen((Position position) {
        final userLatLng = LatLng(position.latitude, position.longitude);
        if (!mounted) return;

        setState(() {
          _currentUserLocation = userLatLng;
        });

        try {
          mapController.animateCamera(CameraUpdate.newLatLng(userLatLng));
        } catch (e) {
          debugPrint('Camera animation error: $e');
        }
      });
    } catch (e) {
      debugPrint('Error starting position stream: $e');
    }
  }

  bool _hasPermission() {
    return permission != null &&
        ![
          LocationPermission.denied,
          LocationPermission.deniedForever,
          LocationPermission.unableToDetermine,
        ].contains(permission);
  }

  @override
  void dispose() {
    debugPrint("💥 RideDetailsScreen disposed");
    positionStreamSubscription?.cancel();
    mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    const textStyle = TextStyle(color: AppConstants.borderColor);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF811E2D),
        title: const Text('Ride Details'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
            debugPrint("👈 Popped context in RideScreen!");
          },
        ),
      ),
      body: Builder(
        builder: (context) {
          try {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: _locationReady
                        ? GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: ride.pickupLocation.coordinates,
                              zoom: 14,
                            ),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            markers: {
                              Marker(
                                markerId: const MarkerId('pickup'),
                                position: ride.pickupLocation.coordinates,
                              ),
                              Marker(
                                markerId: const MarkerId('destination'),
                                position: ride.destinationLocation.coordinates,
                              ),
                              if (_currentUserLocation != null)
                                Marker(
                                  markerId: const MarkerId('you'),
                                  position: _currentUserLocation!,
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueBlue,
                                  ),
                                ),
                            },
                            polylines: {
                              Polyline(
                                polylineId: const PolylineId('route'),
                                points: [
                                  ride.pickupLocation.coordinates,
                                  ride.destinationLocation.coordinates,
                                ],
                                width: 5,
                              )
                            },
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DriverCard(driver: ride.driver),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 18, color: AppConstants.borderColor),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(ride.pickupLocation.name,
                                  style: textStyle,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.flag_outlined,
                                size: 18, color: AppConstants.borderColor),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(ride.destinationLocation.name,
                                  style: textStyle,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Seats Available: ${ride.seatsAvailable - 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Departure: ${ride.departureTime.toLocal().toString().split('.').first}',
                        ),
                        const SizedBox(height: 8),
                        if (ride.description.isNotEmpty) ...[
                          const Text(
                            'Notes:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(ride.description),
                        ],
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "You have successfully joined this ride!",
                            style: TextStyle(
                              color: Color(0xFF811E2D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Open chat or request
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF811E2D)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Text(
                              'Chat with Driver',
                              style: TextStyle(color: Color(0xFF811E2D)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } catch (e, stackTrace) {
            debugPrint('🚨 RideDetailsScreen build error: $e\n$stackTrace');
            return const Center(
              child: Text(
                "Something went wrong while loading the ride details.",
                style: TextStyle(color: Colors.red),
              ),
            );
          }
        },
      ),
    );
  }
}
