import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride History"),
        backgroundColor: const Color(0xFF811E2D),
      ),
      body: Column(
        children: [
          // 🔘 My Rides Button
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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

          // 🧾 Ride History Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rides')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No ride history available."));
                }

                final rides = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final ride = rides[index];
                    final data = ride.data() as Map<String, dynamic>;

                    final rawDate = data["createdAt"];
                    final dateTime = rawDate is Timestamp
                        ? rawDate.toDate()
                        : DateTime.tryParse(rawDate.toString());

                    // User info
                    final userMap =
                        (data["driver"]?["user"] as Map<String, dynamic>?) ??
                            (data["user"] as Map<String, dynamic>?) ??
                            {};
                    final userName = userMap["name"] ?? "Unnamed";
                    final avatar =
                        userMap["imageUrl"] ?? "https://via.placeholder.com/150";

                    // Rating
                    final rating = data["driver"]?["rating"]?.toString() ??
                        data["rating"]?.toString() ??
                        "0.0";

                    // Car details
                    String car = "Unknown";
                    if (data.containsKey("vehicle") &&
                        data["vehicle"] is Map<String, dynamic>) {
                      final v = Map<String, dynamic>.from(data["vehicle"]);
                      final parts = [
                        v["carColor"],
                        v["maker"],
                        v["model"]
                      ].whereType<String>().toList();
                      if (parts.isNotEmpty) {
                        car = parts.join(" ");
                      }
                    }

                    final destination = data["destinationLocation"];
                    final toName = destination?["name"] ?? "";
                    final toAddress = destination?["address"] ?? "";

                    final pickup = data["pickupLocation"];
                    final fromName = pickup?["name"] ?? "";
                    final fromAddress = pickup?["address"] ?? "";

                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(avatar),
                                    radius: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.amber, size: 16),
                                          Text(rating),
                                        ],
                                      ),
                                      Text("Car: ${car.isNotEmpty ? car : "Unknown"}"),
                                      if (dateTime != null)
                                        Text("When: ${DateFormat('M/d/yy, h:mm a').format(dateTime)}"),
                                    ],
                                  )
                                ],
                              ),
                              const Divider(),
                              const Text("FROM -"),
                              Text(fromName),
                              Text(fromAddress),
                              const SizedBox(height: 8),
                              const Text("TO -"),
                              Text(toName),
                              Text(toAddress),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
