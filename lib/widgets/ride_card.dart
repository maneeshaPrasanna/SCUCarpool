import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:santa_clara/constant/constant.dart';
import 'package:santa_clara/models/ride.dart';
import 'package:santa_clara/repositories/user_provider.dart';

class RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback? onJoin;

  const RideCard({super.key, required this.ride, this.onJoin});

  @override
  Widget build(BuildContext context) {
    final pickup = ride.pickupLocation;
    final destination = ride.destinationLocation;
    final driver = ride.driver;
    if (pickup.coordinates.latitude == null ||
        pickup.coordinates.longitude == null ||
        destination.coordinates.latitude == null ||
        destination.coordinates.longitude == null) {
      return const SizedBox(); // or show fallback UI
    }

    final mapUrl = 'https://maps.googleapis.com/maps/api/staticmap?size=600x300'
        '&markers=color:blue%7Clabel:P%7C${pickup.coordinates.latitude},${pickup.coordinates.longitude}'
        '&markers=color:red%7Clabel:D%7C${destination.coordinates.latitude},${destination.coordinates.longitude}'
        '&path=color:0x0000ff|weight:5|${pickup.coordinates.latitude},${pickup.coordinates.longitude}|${destination.coordinates.latitude},${destination.coordinates.longitude}'
        '&key=${AppConstants.kGoogleApiKey}';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : AppConstants.borderColor;
    final textStyle = TextStyle(
      color: isDark ? Colors.white : AppConstants.borderColor,
    );

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppConstants.borderColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              mapUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.map_outlined, size: 100),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driver.user.name,
                    style: textStyle.copyWith(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 18, color: iconColor),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(pickup.name,
                            style: textStyle, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Icon(Icons.flag_outlined, size: 18, color: iconColor),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(destination.name,
                            style: textStyle, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.event_seat, size: 18, color: iconColor),
                    const SizedBox(width: 4),
                    Text('${ride.seatsAvailable} seat(s) available',
                        style: textStyle),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: iconColor),
                    const SizedBox(width: 4),
                    Text(
                      '${ride.departureTime.day}/${ride.departureTime.month} at ${ride.departureTime.hour}:${ride.departureTime.minute.toString().padLeft(2, '0')}',
                      style: textStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (ride.description.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.description_outlined,
                          size: 18, color: iconColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ride.description,
                          style: textStyle,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                if (onJoin != null)
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.borderColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: ride.hasJoined ? null : onJoin,
                      child: Text(
                        ride.hasJoined ? 'Already Joined' : 'Join',
                        style: textStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
