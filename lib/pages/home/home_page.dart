import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:santa_clara/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:santa_clara/models/ride.dart';
import 'package:santa_clara/navigation/my_routes.dart';
import 'package:santa_clara/ride/cubit/ride_cubit.dart';
import 'package:santa_clara/widgets/main_drawer.dart';
import 'package:santa_clara/widgets/ride_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF811E2D), // Maroon color
        iconTheme: const IconThemeData(color: Colors.white), // White icons
        title: const Text('Home'),
        elevation: 2,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      drawer: const MainDrawer(),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF811E2D),
                      ),
                      onPressed: () {
                        context.pushNamed(MyRoutes.planYourRide.name);
                      },
                      child: const Text(
                        'Find a Ride',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF811E2D),
                    ),
                    onPressed: () {
                      context.pushNamed(MyRoutes.offerRide.name);
                    },
                    child: const Text(
                      'Offer a Ride',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )),
                  const SizedBox(height: 16), // optional spacing
                ],
              ),
            ),

            // Search bar that navigates to PlanYourRide
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  context.pushNamed(MyRoutes.planYourRide.name);
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

            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('rides')
                  .where('departureTime',
                      isGreaterThan: DateTime.now().toIso8601String())
                  .where('seatsAvailable', isGreaterThan: 0)
                  .orderBy('createdAt', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No Available Rides at the Moment.'),
                  );
                }

                final rides = snapshot.data!.docs.map((doc) {
                  print('Joining ride: ${doc.id}');
                  final user = context.read<AuthenticationBloc>().user;
                  return Ride.fromMapWithUser(doc.id, doc.data(), user!.uid);
                }).toList();
                return ListView.builder(
                  shrinkWrap: true, // Important for use inside a ScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // Prevents nested scrolling
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final ride = rides[index];
                    return RideCard(
                      ride: ride,
                      onJoin: () async {
                        final user = context.read<AuthenticationBloc>().user;
                        print('Joining ride: ${ride.id}');
                        await context
                            .read<RideCubit>()
                            .joinRide(ride.id, user!);
                        context.read<RideCubit>().selectRide(ride);
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (_) => RideDetailsScreen(ride: ride),
                        //   ),
                        context.pushNamed(MyRoutes.rideDetails.name,
                            extra: ride);
                      },
                    );
                  },
                );
              },
            ),
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
