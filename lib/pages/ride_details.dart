import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:santa_clara/constant/constant.dart';
import 'package:santa_clara/models/ride.dart';
import 'package:santa_clara/widgets/driver_card.dart';

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
    debugPrint("🚀 RideDetailsScreen initState for ride: \${widget.ride.id}");
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
                  'This feature needs location access. Please allow location permissions to continue.'),
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

    setState(() {
      _locationReady = true;
    });

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
          mapController.animateCamera(
            CameraUpdate.newLatLng(userLatLng),
          );
        } catch (e) {
          debugPrint('Camera animation error: \$e');
        }
      });
    } catch (e) {
      debugPrint('Error starting position stream: \$e');
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
        centerTitle: true,
        backgroundColor: const Color(0xFF811E2D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Ride Details'),
        elevation: 2,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Builder(builder: (context) {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "You have successfully joined this ride!",
                          style: TextStyle(
                            color: Color(0xFF811E2D),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      DriverCard(driver: ride.driver),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 18, color: AppConstants.borderColor),
                          const SizedBox(width: 4),
                          Flexible(
                              child: Text(ride.pickupLocation.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF811E2D),
                                  ),
                                  overflow: TextOverflow.ellipsis)),
                          const SizedBox(width: 8),
                          const Icon(Icons.flag_outlined,
                              size: 18, color: AppConstants.borderColor),
                          const SizedBox(width: 4),
                          Flexible(
                              child: Text(ride.destinationLocation.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF811E2D),
                                  ),
                                  overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Seats Available:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            ' ${ride.seatsAvailable - 1}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Departure: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${ride.departureTime.toLocal().toString().split('.').first}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (ride.description.isNotEmpty) ...[
                        const Text(
                          'Notes:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          ride.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        } catch (e, stackTrace) {
          debugPrint('🚨 RideDetailsScreen build error: \$e\n\$stackTrace');
          return const Center(
            child: Text(
              "Something went wrong while loading the ride details.",
              style: TextStyle(color: Colors.red),
            ),
          );
        }
      }),
    );
  }
}
