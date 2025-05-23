import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:santa_clara/location/location_cubit.dart';
import 'package:santa_clara/location/location_helper.dart';
import 'package:santa_clara/location/location_state.dart';
import 'package:santa_clara/models/vehicle.dart';
import 'package:santa_clara/offerRide/cubit/offer_ride_cubit.dart';

import 'package:santa_clara/models/location.dart';
import 'package:santa_clara/repositories/user_provider.dart';

class OfferRidePage extends StatefulWidget {
  const OfferRidePage({super.key});

  @override
  State<OfferRidePage> createState() => _OfferRidePageState();
}

class _OfferRidePageState extends State<OfferRidePage> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  LocationModel? pickupLocation;
  LocationModel? destinationLocation;
  int seatsAvailable = 1;
  String description = '';
  DateTime? departureTime;

  final vehicle = Vehicle(
    maker: 'Tesla',
    model: 'Model 3',
    plate: '1234',
    carColor: 'Red',
  );
  void _submitRide() {
    if (pickupLocation != null &&
        destinationLocation != null &&
        departureTime != null) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      print("thiis is ${user?.name}");
      context.read<OfferRideCubit>().offerRide(
            pickupLocation: pickupLocation!,
            destinationLocation: destinationLocation!,
            seatsAvailable: seatsAvailable,
            description: description,
            departureTime: departureTime!,
            user: Provider.of<UserProvider>(context, listen: false).user!,
            vehicle: vehicle,
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(title: const Text("Offer a Ride")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Pickup Autocomplete
            BlocBuilder<LocationAutocompleteCubit, LocationAutocompleteState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: pickupController,
                      onChanged: (value) {
                        context.read<LocationAutocompleteCubit>().search(value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Pickup Location',
                      ),
                    ),
                    if (state is LocationLoaded)
                      ...state.predictions.map(
                        (p) => ListTile(
                          title: Text(p.primaryText ?? ''),
                          subtitle: Text(p.secondaryText ?? ''),
                          onTap: () async {
                            final loc = await getPlaceDetailFromPrediction(p);
                            if (loc != null) {
                              setState(() {
                                pickupLocation = loc;
                                pickupController.text = loc.name;
                              });
                              context
                                  .read<LocationAutocompleteCubit>()
                                  .emit(LocationInitial());
                            }
                          },
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Destination Autocomplete
            BlocBuilder<LocationAutocompleteCubit, LocationAutocompleteState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: destinationController,
                      onChanged: (value) {
                        context.read<LocationAutocompleteCubit>().search(value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Destination Location',
                      ),
                    ),
                    if (state is LocationLoaded)
                      ...state.predictions.map(
                        (p) => ListTile(
                          title: Text(p.primaryText ?? ''),
                          subtitle: Text(p.secondaryText ?? ''),
                          onTap: () async {
                            final loc = await getPlaceDetailFromPrediction(p);
                            if (loc != null) {
                              setState(() {
                                destinationLocation = loc;
                                destinationController.text = loc.name;
                              });
                              context
                                  .read<LocationAutocompleteCubit>()
                                  .emit(LocationInitial());
                            }
                          },
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Seats
            DropdownButtonFormField<int>(
              value: seatsAvailable,
              decoration: const InputDecoration(labelText: "Seats Available"),
              onChanged: (value) => setState(() => seatsAvailable = value!),
              items: List.generate(6, (i) => i + 1)
                  .map((s) => DropdownMenuItem(value: s, child: Text('$s')))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // DateTime
            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 30)),
                );
                if (picked != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(now),
                  );
                  if (time != null) {
                    setState(() {
                      departureTime = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
              child: Text(departureTime == null
                  ? "Select Departure Time"
                  : departureTime.toString()),
            ),

            const SizedBox(height: 16),

            // Description
            TextField(
              decoration: const InputDecoration(labelText: "Description"),
              onChanged: (value) => description = value,
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitRide,
              child: const Text("Offer Ride"),
            ),
          ],
        ),
      ),
    );
  }
}
