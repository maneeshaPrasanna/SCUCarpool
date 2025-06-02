import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:santa_clara/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:santa_clara/constant/constant.dart';
import 'package:santa_clara/models/ride.dart';
import 'package:santa_clara/navigation/my_routes.dart';
import 'package:santa_clara/pages/ride_details.dart';
import 'package:santa_clara/ride/cubit/ride_cubit.dart';
import 'package:santa_clara/ride/cubit/ride_state.dart';
import 'package:santa_clara/widgets/ride_card.dart';

class RideScreen extends StatefulWidget {
  const RideScreen({super.key});

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> with WidgetsBindingObserver {
  LocationPermission? permission;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    // Load when screen is first created
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed && mounted) {
  //     Future.delayed(const Duration(milliseconds: 500), () {
  //       if (mounted) {
  //         context.read<RideCubit>().loadRides();
  //       }
  //     });
  //   }
  // }

  Future<void> _navigateToDetails(Ride ride) async {
    final user = context.read<AuthenticationBloc>().user;
    if (_navigated) return;
    _navigated = true;

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        if (!context.mounted) return;
        await context.read<RideCubit>().joinRide(ride.id, user!);
        context.read<RideCubit>().selectRide(ride);

        final result =
            await context.pushNamed(MyRoutes.rideDetails.name, extra: ride);

        if (result == true && mounted) {
          context.read<RideCubit>().loadRides();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission is required.")),
          );
        }
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
    } finally {
      _navigated = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.borderColor,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text("Available Rides"),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<RideCubit, RideState>(
        builder: (context, state) {
          if (state is RideLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RideLoaded) {
            if (state.rides.isEmpty) {
              return const Center(child: Text("No rides available."));
            }
            return ListView.builder(
              itemCount: state.rides.length,
              itemBuilder: (context, index) {
                final ride = state.rides[index];
                return RideCard(
                  ride: ride,
                  onJoin: () => _navigateToDetails(ride),
                );
              },
            );
          } else if (state is RideError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.red)),
            );
          } else {
            return const Center(
              child: Text("Search for rides to get started."),
            );
          }
        },
      ),
    );
  }
}
