import 'package:flutter/material.dart';
import 'package:santa_clara/pages/offer_ride.dart';
import 'package:santa_clara/pages/search_page.dart';
import '../chat/chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF811E2D), // Maroon color

        title: const Text('Carpool App'),
        elevation: 2,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Find a Ride and Offer a Ride buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlanYourRidePage()),
                        );
                      },
                      child: const Text('Find a Ride'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OfferRidePage()),
                        );
                      },
                      child: const Text('Offer a Ride'),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar that navigates to PlanYourRide
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlanYourRidePage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Where to?', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 32, thickness: 1),

            // Available Carpools section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Available Carpool',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  },
  child: const Text("Open Chat"),
),

            // Carpool listing
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.grey.shade300),
            //       borderRadius: BorderRadius.circular(8.0),
            //     ),
            //     child: Padding(
            //       padding: const EdgeInsets.all(16.0),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           const Text(
            //             'Driver_name',
            //             style: TextStyle(fontWeight: FontWeight.bold),
            //           ),
            //           const SizedBox(height: 8),
            //           const Text('Sunnyvale'),
            //           const SizedBox(height: 4),
            //           const Text('SCU'),
            //           const SizedBox(height: 4),
            //           const Text('3 seats available'),
            //           const SizedBox(height: 4),
            //           const Text('05/05/2025 5pm'),
            //           const SizedBox(height: 4),
            //           const Text('pick-up location is Sunnyvale transit center, waiting for 10 min'),
            //           const SizedBox(height: 16),
            //           Align(
            //             alignment: Alignment.centerRight,
            //             child: ElevatedButton(
            //               onPressed: () {
            //                 // Handle join action
            //               },
            //               child: const Text('Join'),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.list_alt),
      //       label: 'Activity',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Account',
      //     ),
      //   ],
      //   currentIndex: 0,
      //   selectedItemColor: Colors.blue,
      //   onTap: (index) {
      //     // Handle bottom nav bar taps
      //   },
      // ),
    );
  }
}
