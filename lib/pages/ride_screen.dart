import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:santa_clara/constant/constant.dart';
import 'package:santa_clara/navigation/my_routes.dart';
import 'package:santa_clara/pages/ride_details.dart';
import 'package:santa_clara/ride/cubit/ride_cubit.dart';
import 'package:santa_clara/ride/cubit/ride_state.dart';
import 'package:santa_clara/widgets/ride_card.dart';

class RideScreen extends StatelessWidget {
  const RideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.borderColor,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pop(context); // Or handle custom logic
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
                  onJoin: () {
                    // Implement join ride logic
                    context.read<RideCubit>().selectRide(ride);
                    // 2) navigate to details, passing ride
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => RideDetailsScreen(ride: ride),
                    ));

                    // final location = GoRouterState.of(context).uri.toString();
                    // print('➡️ Current location: $location');

                    // context.pushNamed(MyRoutes.rideDetails.name,
                    //     extra: ride // Pass the ride object )
                    //     );
                    // if (context.mounted) {
                    //   print('peopleijnngg');
                    //   context.read<RideCubit>().loadRides();
                    // }
                  },
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
                child: Text("Search for rides to get started."));
          }
        },
      ),
    );
  }
}
