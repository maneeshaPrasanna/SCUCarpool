import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:santa_clara/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:santa_clara/widgets/brightness_selector.dart';
import 'package:santa_clara/widgets/email_verification_button.dart';
import 'package:santa_clara/widgets/logged_in_user_avatar.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key, this.navigationItems});
  final List<Widget>? navigationItems;

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  File? _avatarFile;

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.gallery); // 从图库选择图片
    if (pickedImage != null) {
      setState(() {
        _avatarFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _editUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final doc = await docRef.get();
  final currentName = doc.data()?['name'] ?? '';
  final currentPhone = doc.data()?['phoneNumber'] ?? '';

  final nameController = TextEditingController(text: currentName);
  final phoneController = TextEditingController(text: currentPhone);

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await docRef.update({
                'name': nameController.text.trim(),
                'phoneNumber': phoneController.text.trim(),
              });
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
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
              DrawerHeader(
                child: Container(
                  width: double.infinity,
                  height: 400,
                  child: _avatarFile != null
                      ? CircleAvatar(
                          radius: 80,
                          backgroundImage: FileImage(_avatarFile!),
                        )
                      : const LoggedInUserAvatar(
                          userAvatarSize: UserAvatarSize.large,
                        ),
                ),
              ),
              if (widget.navigationItems != null) ...widget.navigationItems!,
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Change Avatar"),
                onPressed: _pickAvatarImage,
              ),
              TextButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                onPressed: _editUserProfile,
              ),

              TextButton.icon(
                icon: const Icon(Icons.commute),
                label: const Text("My Car"),
                onPressed: () {},
              ),
               TextButton.icon(
                icon: const Icon(Icons.help),
                label: const Text("Help"),
                onPressed: () {},
              ),
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
}
