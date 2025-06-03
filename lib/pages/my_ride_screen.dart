import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:santa_clara/blocs/authentication/bloc/authentication_bloc.dart';

import 'package:santa_clara/ride/cubit/ride_cubit.dart';
import 'package:santa_clara/ride/cubit/ride_state.dart';
import 'package:santa_clara/widgets/ride_card.dart';
import 'package:go_router/go_router.dart';

class MyRideScreen extends StatefulWidget {
  const MyRideScreen({super.key});

  @override
  State<MyRideScreen> createState() => _MyRideScreenState();
}

class _MyRideScreenState extends State<MyRideScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthenticationBloc>().user;
    if (user != null) {
      context.read<RideCubit>().loadMyRidesSplit(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF811E2D), // Maroon color
        iconTheme: const IconThemeData(color: Colors.white), // White icons
        title: const Text('Activity'),
        elevation: 2,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: BlocBuilder<RideCubit, RideState>(
        builder: (context, state) {
          if (state is RideLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RideSplitLoaded) {
            return ListView(
              padding: const EdgeInsets.all(8),
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.push('/ride-history');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF811E2D),
                  ),
                  child: const Text(
                    "Ride History",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                if (state.upcoming.isNotEmpty) ...[
                  const Text("Upcoming Rides",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...state.upcoming
                      .map((ride) => RideCard(ride: ride, onJoin: null)),
                  const SizedBox(height: 16),
                ],
                if (state.past.isNotEmpty) ...[
                  const Text("Past Rides",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...state.past
                      .map((ride) => RideCard(ride: ride, onJoin: null)),
                ],
                if (state.upcoming.isEmpty && state.past.isEmpty)
                  const Center(child: Text("You haven't posted any rides.")),
              ],
            );
          } else if (state is RideError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.red)),
            );
          } else {
            return const Center(child: Text("No rides to show."));
          }
        },
      ),
    );
  }
}
