import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:santa_clara/navigation/my_routes.dart';
import 'package:santa_clara/ride/cubit/ride_cubit.dart';
import 'package:santa_clara/ride/cubit/ride_state.dart';
import 'package:santa_clara/widgets/pickup_where_to_card.dart';
//import 'package:santa_clara/widgets/pickup_where_to_card.dart';

class PlanYourRidePage extends StatefulWidget {
  const PlanYourRidePage({super.key}); // Maroon color
  @override
  State<PlanYourRidePage> createState() => _PlanYourRidePageState();
}

class _PlanYourRidePageState extends State<PlanYourRidePage> {
  Color maroon = const Color(0xFF811E2D); // Maroon color
  @override
  void initState() {
    super.initState();
    // Clear any previous search state when this page is loaded
    Future.delayed(Duration.zero, () {
      context.read<RideCubit>().clearRideSearchState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: maroon,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            //Navigator.pop(context); // Or handle custom logic
          },
        ),
        title: const Text("Plan Your Ride"),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<RideCubit, RideState>(
          listenWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType,
          listener: (context, state) {
            if (state is RideLoaded) {
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (_) => const RideScreen()),
              // );
              context.pushNamed(MyRoutes.rideScreen.name);
              //context.read<RideCubit>().clearRideSearchState();
            }
            if (state is RideError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: const Column(
            children: [
              // Input card
              Padding(
                padding: EdgeInsets.all(16.0),
                child: PickupWhereToCard(),
              ),
              // FloatingActionButton(
              //   child: const Icon(Icons.cloud_upload),
              //   onPressed: () async {
              //     await seedSampleRides();
              //     print('Sample rides seeded!');
              //   },
              // )
            ],
          ),
        ),
      ),
    );
  }
}
