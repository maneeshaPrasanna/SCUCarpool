
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RideHistoryScreen extends StatelessWidget {
  RideHistoryScreen({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
        backgroundColor: const Color(0xFF7A1F2D),
        leading: const BackButton(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(ride["image"]),
                      radius: 28,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride["name"],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(ride["rating"].toString(), style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                        Text("Car: \${ride['car']}"),
                        Text("When: \${DateFormat('M/d/yy, h:mm a').format(ride['dateTime'])}"),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildLocation(Icons.location_on, ride["from"][0], ride["from"][1]),
                const SizedBox(height: 6),
                _buildLocation(Icons.location_on_outlined, ride["to"][0], ride["to"][1]),
                const Divider(thickness: 1, height: 30),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF7A1F2D),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }

  Widget _buildLocation(IconData icon, String title, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(address),
            ],
          ),
        ),
      ],
    );
  }
}