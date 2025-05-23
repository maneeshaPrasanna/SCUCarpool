import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santa_clara/pages/car/car_page.dart';
import 'package:santa_clara/widgets/email_verification_button.dart';
import 'package:santa_clara/widgets/logged_in_user_avatar.dart';
import 'package:santa_clara/pages/profile/profile_page.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key, this.navigationItems});
  final List<Widget>? navigationItems;

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final user = FirebaseAuth.instance.currentUser;

  Map<String, dynamic>? carData;

  String email = '';
  String name = '';
  String phone = '';
  String avatarUrl = '';
  String maker = '';
  String model = '';
  String carColor = '';
  String plate= '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCarData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final data = doc.data() ?? {};
    setState(() {
      name = data['name'] ?? '';
      phone = data['phoneNumber'] ?? '';
      email = user!.email ?? '';
      avatarUrl = data['avatarUrl'] ?? '';
    });
  }

  Future<void> _loadCarData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('cars').doc(user!.uid).get();
    final data = doc.data() ?? {};
    setState(() {
      carData = data;
      maker = data['maker'] ?? '';
      model = data['model'] ?? '';
      carColor = data['carColor'] ?? '';
      plate = data['plate'] ?? '';
    });
      
    
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: avatarUrl.isNotEmpty
                    ? CircleAvatar(radius: 60, backgroundImage: NetworkImage(avatarUrl))
                    : const LoggedInUserAvatar(userAvatarSize: UserAvatarSize.large),
              ),
              const SizedBox(height: 16),
        
              // Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Divider(color: const Color.fromARGB(255, 129, 30, 45)),

                      const Text("Profile",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold  ),),
                        
                     
                      const SizedBox(height: 10),
                      _buildInfoRow(label: 'Name', value: name),
                      const SizedBox(height: 10),
                      _buildInfoRow(label: 'Phone', value: phone),

                      if (carData != null) ...[
                        const SizedBox(height: 10),
                        const Divider(color: const Color.fromARGB(255, 129, 30, 45)),
                        const Text("Car Information",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        const SizedBox(height: 10),
                        _buildInfoRow(label: 'Maker', value: maker),
                        const SizedBox(height: 10),
                        _buildInfoRow(label: 'Model', value: model),
                        const SizedBox(height: 10),
                        _buildInfoRow(label: 'Color', value: carColor),
                        const SizedBox(height: 10),
                        _buildInfoRow(label: 'Plate', value: plate),
                        const Divider(color: const Color.fromARGB(255, 129, 30, 45)),
                        
                      ],
                    ],
                  ),
                ),
              ),
              
              // profile
              TextButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                  if (result == true) {
                    await _loadUserData(); // load user data
                  }
                },
              ),  

              // add/edit car info
              TextButton.icon(
                icon: const Icon(Icons.emoji_transportation),
                label: Text(carData == null ? "Add a Car" : "Edit Car Info"),
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CarPage()),
                  );
                  if (result == true) {
                    setState(() => carData = null);
                    await _loadCarData(); // 重新加载车辆信息
                  }
                },
              ),

              const EmailVerificationButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'Not provided',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
