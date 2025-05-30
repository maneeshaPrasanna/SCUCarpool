import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:santa_clara/constant/constant.dart';
import 'package:santa_clara/location/location_cubit.dart';
import 'package:santa_clara/location/location_helper.dart';
import 'package:santa_clara/location/location_state.dart';
import 'package:santa_clara/ride/cubit/ride_cubit.dart';

import '../models/location.dart';

class PickupWhereToCard extends StatefulWidget {
  const PickupWhereToCard({super.key});

  @override
  _PickupWhereToCardState createState() => _PickupWhereToCardState();
}

class _PickupWhereToCardState extends State<PickupWhereToCard> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  bool isTypingPickup = true;

  LocationModel? pickupLocation;
  LocationModel? destinationLocation;

  void _checkAndSearchRides() {
    print("hiii####################################");
    if (pickupLocation != null) {
      context.read<RideCubit>().setPickup(pickupLocation!);
    }
    if (destinationLocation != null) {
      context.read<RideCubit>().setDestination(destinationLocation!);
    }
    print(
        "Pickup: ${pickupLocation?.address}, Destination: ${destinationLocation?.address}");
  }

  // void _checkAndSearchRides() {
  //   if (pickupLocation != null && destinationLocation != null) {
  //     context.read<RideCubit>().searchRides(
  //           pickup: pickupLocation!,
  //           destination: destinationLocation!,
  //         );
  //     // Optional: Navigate to another screen or show results.
  //     // Navigator.push(context, MaterialPageRoute(builder: (_) => RideResultsPage()));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 300,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppConstants.borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextField(
                  controller: pickupController,
                  decoration: const InputDecoration(hintText: "Enter Pickup"),
                  onChanged: (val) {
                    setState(() => isTypingPickup = true);
                    context.read<LocationAutocompleteCubit>().search(val);
                  },
                ),
              ),
              const Divider(thickness: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextField(
                  controller: destinationController,
                  decoration: const InputDecoration(hintText: "Where To?"),
                  onChanged: (val) {
                    setState(() => isTypingPickup = false);
                    context.read<LocationAutocompleteCubit>().search(val);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        BlocBuilder<LocationAutocompleteCubit, LocationAutocompleteState>(
          builder: (context, state) {
            if (state is LocationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LocationLoaded) {
              return SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: state.predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = state.predictions[index];
                    return ListTile(
                      leading: const Icon(Icons.location_pin,
                          color: AppConstants.borderColor),
                      title: Text(
                          prediction.primaryText ?? prediction.fullText ?? ''),
                      subtitle: Text(prediction.secondaryText ?? ''),
                      onTap: () async {
                        final location =
                            await getPlaceDetailFromPrediction(prediction);
                        if (location != null) {
                          if (isTypingPickup) {
                            pickupController.text = location.name;
                            pickupLocation = location;
                          } else {
                            destinationController.text = location.name;
                            destinationLocation = location;
                          }
                          _checkAndSearchRides();
                        }
                      },
                    );
                  },
                ),
              );
            } else if (state is LocationError) {
              return Text(state.message,
                  style: const TextStyle(color: Colors.red));
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    ),
    );
  }
}
