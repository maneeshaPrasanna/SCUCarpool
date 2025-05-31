import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class RideHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> rides = [
    {
      "name": "John Doe",
      "rating": 4.8,
      "car": "Toyota Prius, Blue",
      "dateTime": DateTime(2025, 5, 5, 18, 0),
      "from": ["Glenbrook Apartments", "10150 Parkwood Dr #3, Cupertino, CA"],
      "to": ["Santa Clara University", "500El Camino Real, Santa Clara ,CA"],
      "image": "https://via.placeholder.com/150",
    },
    {
      "name": "Ben Root",
      "rating": 4.6,
      "car": "Honda Accord, Blue",
      "dateTime": DateTime(2025, 5, 1, 19, 11),
      "from": ["San Jose State University", "1 Washington Sq, San Jose, CA"],
      "to": ["Santa Clara University", "500El Camino Real, Santa Clara ,CA"],
      "image": "https://via.placeholder.com/150",
    },
  ];

  RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
        backgroundColor: const Color(0xFF811E2D),
      ),
      body: Column(
        children: [
          // 🔘 My Rides Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: ElevatedButton(
              onPressed: () {
                context.go('/activity'); // ⬅️ Go to MyRideScreen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF811E2D),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  "My Rides",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 🧾 Ride History List
          Expanded(
            child: ListView.builder(
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(ride["image"])),
                  title: Text(ride["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("⭐ ${ride['rating']} • ${ride['car']}"),
                      Text("When: ${DateFormat.yMd().add_jm().format(ride["dateTime"])}"),
                      const SizedBox(height: 4),
                      Text("FROM - ${ride['from'][0]}\n${ride['from'][1]}"),
                      Text("TO - ${ride['to'][0]}\n${ride['to'][1]}"),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
