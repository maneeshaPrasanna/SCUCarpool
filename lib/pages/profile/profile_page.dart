import 'package:santa_clara/widgets/logged_in_user_avatar.dart';
import 'package:santa_clara/widgets/main_drawer.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MainDrawer(),
         appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "SCU Carpool",
          style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold,fontSize: 24),
        ),
        backgroundColor: const Color.fromARGB(255, 129, 30, 45),
      ),
        body: Center(child: Text("Profile")));
  }
}
