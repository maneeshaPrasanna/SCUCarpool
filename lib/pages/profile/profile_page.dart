import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:santa_clara/widgets/logged_in_user_avatar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  String email = '';
  String avatarUrl = '';
  bool isEditing = true;
  File? _newAvatarFile;

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

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newAvatarFile = File(picked.path);
      });
    }
  }

  Future<String?> _uploadAvatar(File file) async {
    final ref =
        FirebaseStorage.instance.ref().child('avatars/${user!.uid}.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    if (user == null) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    String newAvatarUrl = avatarUrl;
    if (_newAvatarFile != null) {
      newAvatarUrl = await _uploadAvatar(_newAvatarFile!) ?? avatarUrl;
    }

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'name': nameController.text.trim(),
      'phoneNumber': phoneController.text.trim(),
      'avatarUrl': newAvatarUrl,
    });
    await currentUser?.updateDisplayName(nameController.text.trim());
    await currentUser?.updatePhotoURL(newAvatarUrl);

    // Optional: Reload the user to get updated values
    await currentUser?.reload();
    final rideSnapshot = await FirebaseFirestore.instance
        .collection('rides')
        .where('driver.user.uid', isEqualTo: user!.uid)
        .get();

    for (var doc in rideSnapshot.docs) {
      await doc.reference.update({
        'driver.user.name': nameController.text.trim(),
        'driver.user.phoneNumber': phoneController.text.trim(),
        'driver.user.imageUrl': newAvatarUrl,
      });
    }
    setState(() {
      isEditing = false;
      avatarUrl = newAvatarUrl;
      _newAvatarFile = null;
    });

    if (mounted) {
      Navigator.pop(context,true); // 返回上一页
    }

    //ScaffoldMessenger.of(context).showSnackBar(
    //  const SnackBar(content: Text('Profile updated')),
    //);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF811E2D), // Maroon color
        iconTheme: const IconThemeData(color: Colors.white), // White icons
        title: const Text('My Profile'),
        elevation: 2,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: isEditing ? _pickAvatar : null,
              child: _newAvatarFile != null
                  ? CircleAvatar(
                      radius: 60,
                      backgroundImage: FileImage(_newAvatarFile!),
                    )
                  : avatarUrl.isNotEmpty
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(avatarUrl),
                        )
                      : const LoggedInUserAvatar(
                          userAvatarSize: UserAvatarSize.large),
            ),
            const SizedBox(height: 10),
            
            TextField(
              controller: nameController,
              enabled: isEditing,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              enabled: false,
              decoration: InputDecoration(labelText: 'Email', hintText: email),
            ),
            TextField(
              controller: phoneController,
              enabled: isEditing,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 20),
            SizedBox(
  width: double.infinity,
  child:
            ElevatedButton(
              onPressed: isEditing
                  ? _saveProfile
                  : () => setState(() => isEditing = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 129, 30, 45),
                foregroundColor: Colors.white, // ✅ 设置字体颜色
                
              ),
              child: const Text('Save'),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
