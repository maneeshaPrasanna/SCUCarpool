import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:santa_clara/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:santa_clara/widgets/main_drawer.dart';
import 'package:santa_clara/ride/cubit/ride_cubit.dart';
import 'package:santa_clara/ride/cubit/ride_state.dart';
import 'package:santa_clara/widgets/ride_card.dart';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const MainDrawer(),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFF811E2D),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Activity'),
          elevation: 2,
          titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bottom: const TabBar(
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: 'As a Driver'),
              Tab(text: 'As a Passenger'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            _buildRideList(isDriver: true),
            _buildRideList(isDriver: false),
          ],
        ),
      ),
    );
  }

  Widget _buildRideList({required bool isDriver}) {
    return BlocBuilder<RideCubit, RideState>(
      builder: (context, state) {
        if (state is RideLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RideSplitLoaded) {
          final user = context.read<AuthenticationBloc>().user!;
          final upcoming = isDriver
              ? state.upcoming
                  .where((r) => r.driver.user.uid == user.uid)
                  .toList()
              : state.upcoming.where((r) => r.hasJoined).toList();

          final past = isDriver
              ? state.past.where((r) => r.driver.user.uid == user.uid).toList()
              : state.past.where((r) => r.hasJoined).toList();

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              const SizedBox(height: 16),
              if (upcoming.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Upcoming Rides",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ...upcoming.map((ride) => RideCard(ride: ride, onJoin: null)),
                const SizedBox(height: 16),
              ],
              if (past.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Past Rides",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ...past.map((ride) => RideCard(ride: ride, onJoin: null)),
              ],
              if (upcoming.isEmpty && past.isEmpty)
                const Center(child: Text("No rides to show.")),
            ],
          );
        } else if (state is RideError) {
          return Center(
            child:
                Text(state.message, style: const TextStyle(color: Colors.red)),
          );
        } else {
          return const Center(child: Text("No rides to show."));
        }
      },
    );
  }
}
