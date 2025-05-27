import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:santa_clara/location/location_cubit.dart';
import 'package:santa_clara/location/location_helper.dart';
import 'package:santa_clara/location/location_state.dart';
import 'package:santa_clara/models/location.dart';
import 'package:santa_clara/constant/constant.dart';

class OfferRideLocationBottomSheet extends StatefulWidget {
  const OfferRideLocationBottomSheet({super.key});

  @override
  State<OfferRideLocationBottomSheet> createState() =>
      _OfferRideLocationBottomSheetState();
}

class _OfferRideLocationBottomSheetState
    extends State<OfferRideLocationBottomSheet> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  bool isTypingPickup = true;

  LocationModel? pickupLocation;
  LocationModel? destinationLocation;

  void _tryReturn() {
    if (pickupLocation != null && destinationLocation != null) {
      Navigator.pop<Map<String, LocationModel>>(context, {
        'pickup': pickupLocation!,
        'destination': destinationLocation!,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 5,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            TextField(
              controller: pickupController,
              decoration: const InputDecoration(hintText: 'Enter Pickup'),
              onChanged: (val) {
                setState(() => isTypingPickup = true);
                context.read<LocationAutocompleteCubit>().search(val);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: destinationController,
              decoration: const InputDecoration(hintText: 'Enter Destination'),
              onChanged: (val) {
                setState(() => isTypingPickup = false);
                context.read<LocationAutocompleteCubit>().search(val);
              },
            ),
            const SizedBox(height: 10),
            BlocBuilder<LocationAutocompleteCubit, LocationAutocompleteState>(
              builder: (context, state) {
                if (state is LocationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is LocationLoaded) {
                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: state.predictions.length,
                      itemBuilder: (context, index) {
                        final prediction = state.predictions[index];
                        return ListTile(
                          leading: const Icon(Icons.location_pin,
                              color: AppConstants.borderColor),
                          title: Text(prediction.primaryText ??
                              prediction.fullText ??
                              ''),
                          subtitle: Text(prediction.secondaryText ?? ''),
                          onTap: () async {
                            final location =
                                await getPlaceDetailFromPrediction(prediction);
                            if (location != null) {
                              if (isTypingPickup) {
                                pickupLocation = location;
                                pickupController.text = location.name;
                              } else {
                                destinationLocation = location;
                                destinationController.text = location.name;
                              }
                              _tryReturn();
                            }
                          },
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
