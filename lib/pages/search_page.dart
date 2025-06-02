import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:santa_clara/navigation/my_routes.dart';
import 'package:santa_clara/pages/ride_screen.dart';
import 'package:santa_clara/pages/sample_rides.dart';
import 'package:santa_clara/pages/update.dart';
import 'package:santa_clara/ride/cubit/ride_cubit.dart';
import 'package:santa_clara/ride/cubit/ride_state.dart';
import 'package:santa_clara/widgets/pickup_where_to_card.dart';

class PlanYourRidePage extends StatefulWidget {
  const PlanYourRidePage({super.key});

  @override
  State<PlanYourRidePage> createState() => _PlanYourRidePageState();
}

class _PlanYourRidePageState extends State<PlanYourRidePage> {
  Color maroon = const Color(0xFF811E2D); // Maroon color

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<RideCubit>().clearRideSearchState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: maroon,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
      body: BlocListener<RideCubit, RideState>(
        listenWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        listener: (context, state) {
          if (state is RideLoaded) {
            context.pushNamed(MyRoutes.rideScreen.name);
          }
          if (state is RideError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: const PickupWhereToCard(),
        ),
      ),
    );
  }
}
