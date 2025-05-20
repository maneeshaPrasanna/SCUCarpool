import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santa_clara/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:santa_clara/widgets/brightness_selector.dart';
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

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  String email = '';
  String avatarUrl = '';
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final data = doc.data() ?? {};
    setState(() {
      nameController.text = data['name'] ?? '';
      phoneController.text = data['phoneNumber'] ?? '';
      email = user!.email ?? '';
      avatarUrl = data['avatarUrl'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ✅ Avatar 居中
              Center(
                child: avatarUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(avatarUrl),
                      )
                    : const LoggedInUserAvatar(
                        userAvatarSize: UserAvatarSize.large),
              ),

              const SizedBox(height: 16),

              Card(
                elevation: 0, // ✅ 去掉阴影
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)), // ✅ 可选：去圆角
                color: Colors.transparent,

                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(label: 'Name', value: nameController.text),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                          label: 'Phone', value: phoneController.text),
                    ],
                  ),
                ),
              ),

              TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  }),

              const EmailVerificationButton(),
              TextButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Sign Out"),
                onPressed: () {
                  BlocProvider.of<AuthenticationBloc>(context)
                      .add(AuthenticationSignOutEvent());
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  "Display settings",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const BrightnessSelector(),
            ]),
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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
