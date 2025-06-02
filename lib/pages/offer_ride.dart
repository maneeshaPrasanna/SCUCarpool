import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:santa_clara/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:santa_clara/constant/constant.dart';
import 'package:santa_clara/models/location.dart';
import 'package:santa_clara/offerRide/cubit/offer_ride_cubit.dart';
import 'package:santa_clara/offerRide/cubit/offer_ride_state.dart';
import 'package:santa_clara/widgets/offer_ride_location.dart';

import '../../widgets/pickup_where_to_card.dart';
import '../../widgets/main_drawer.dart';

class OfferRidePage extends StatefulWidget {
  const OfferRidePage({super.key});

  @override
  State<OfferRidePage> createState() => _OfferRidePageState();
}

class _OfferRidePageState extends State<OfferRidePage> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  int seatsAvailable = 1;
  DateTime? selectedDateTime;
  LocationModel? pickupLocation;
  LocationModel? destinationLocation;
  String description = '';
  String? mapUrl;
  bool isRidePosted = false;
  void _submitRide() {
    if (pickupLocation != null &&
        destinationLocation != null &&
        selectedDateTime != null) {
      final user = context.read<AuthenticationBloc>().user;
      print("user.imageee ${user?.imageUrl}");
      if (user == null) return;
      context.read<OfferRideCubit>().offerRide(
            pickupLocation: pickupLocation!,
            destinationLocation: destinationLocation!,
            seatsAvailable: seatsAvailable,
            description: notesController.text,
            departureTime: selectedDateTime!,
            user: user,
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OfferRideCubit, OfferRideState>(
        listener: (context, state) {
          if (state is OfferRideSuccess) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("✅ Ride Posted"),
                content: const Text("Your ride has been successfully posted."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() => isRidePosted = true); // close dialog
                      //Navigator.of(context)
                      //.pop(true); // go back to previous screen
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          } else if (state is OfferRideError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: const Color(0xFF811E2D),
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('Offer a Ride'),
            elevation: 2,
            titleTextStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationInput(
                  icon: Icons.location_on_outlined,
                  hintText: 'Pickup Location',
                  controller: pickupController,
                  onTap: () async {
                    final result =
                        await showModalBottomSheet<Map<String, LocationModel>>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) => const OfferRideLocationBottomSheet(),
                    );

                    if (result != null) {
                      setState(() {
                        pickupLocation = result['pickup'];
                        destinationLocation = result['destination'];
                        pickupController.text = pickupLocation?.name ?? '';
                        destinationController.text =
                            destinationLocation?.name ?? '';

                        if (pickupLocation != null &&
                            destinationLocation != null) {
                          mapUrl =
                              'https://maps.googleapis.com/maps/api/staticmap?size=600x300'
                              '&markers=color:blue%7Clabel:P%7C${pickupLocation!.coordinates.latitude},${pickupLocation!.coordinates.longitude}'
                              '&markers=color:red%7Clabel:D%7C${destinationLocation!.coordinates.latitude},${destinationLocation!.coordinates.longitude}'
                              '&path=color:0x0000ff|weight:5|${pickupLocation!.coordinates.latitude},${pickupLocation!.coordinates.longitude}|${destinationLocation!.coordinates.latitude},${destinationLocation!.coordinates.longitude}'
                              '&key=${AppConstants.kGoogleApiKey}';
                        }
                      });
                    }
                  },
                ),
                _buildLocationInput(
                  icon: Icons.flag_outlined,
                  hintText: 'Destination',
                  controller: destinationController,
                  onTap: () async {
                    final LocationModel? result = await showDialog(
                      context: context,
                      builder: (_) => const PickupWhereToCard(),
                    );
                    if (result != null) {
                      setState(() {
                        //destinationController.text = result.placeName;
                      });
                    }
                  },
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: mapUrl != null
                      ? Padding(
                          key: ValueKey(
                              mapUrl), // Important for AnimatedSwitcher to detect changes
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              mapUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 150,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 150,
                                color: Colors.grey.shade300,
                                alignment: Alignment.center,
                                child:
                                    const Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                _buildDateTimePicker(),
                _buildDropdownField(),
                _buildTextField(
                  icon: Icons.attach_money,
                  controller: priceController,
                  hintText: 'Price (optional)',
                  keyboardType: TextInputType.number,
                  readOnly:
                      isRidePosted, // Read-only since it's auto-calculated
                ),
                _buildTextField(
                    icon: Icons.notes,
                    controller: notesController,
                    hintText: 'Additional notes...',
                    maxLines: 3,
                    readOnly: isRidePosted),
                const SizedBox(height: 20),
                if (!isRidePosted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF811E2D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        final pickup = pickupController.text;
                        final destination = destinationController.text;
                        final price = priceController.text;
                        final notes = notesController.text;

                        if (pickup.isEmpty ||
                            destination.isEmpty ||
                            selectedDateTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please complete all required fields')),
                          );
                          return;
                        }

                        _submitRide();
                      },
                      child: const Text(
                        'Submit Ride',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ));
  }

  Widget _buildLocationInput({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF811E2D)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        enabled: !isRidePosted,
        onTap: onTap,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.black),
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return _buildLocationInput(
      icon: Icons.calendar_today,
      hintText: selectedDateTime == null
          ? 'Select date and time'
          : DateFormat('MMM dd, yyyy - hh:mm a').format(selectedDateTime!),
      controller: TextEditingController(text: ''),
      onTap: isRidePosted
          ? () {}
          : () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                }
              }
            },
    );
  }

  Widget _buildDropdownField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF811E2D)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        value: seatsAvailable,
        decoration: const InputDecoration(
          icon: Icon(Icons.person_outline),
          border: InputBorder.none,
        ),
        items: List.generate(5, (index) => index + 1)
            .map((seat) => DropdownMenuItem(
                  value: seat,
                  child: Text('$seat seat${seat > 1 ? 's' : ''} available'),
                ))
            .toList(),
        onChanged: isRidePosted
            ? null
            : (value) {
                setState(() {
                  seatsAvailable = value!;
                });
              },
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF811E2D)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.black),
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
    );
  }
}
