import 'package:santa_clara/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:santa_clara/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:santa_clara/widgets/brightness_selector.dart';
class SettingPage extends StatelessWidget {
  const SettingPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF811E2D), // Maroon color
        iconTheme: const IconThemeData(color: Colors.white), // White icons
        title: const Text('Settings'),
        elevation: 2,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Container(
  padding: const EdgeInsets.all(16.0), 
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Display Settings",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          
        ),
      ),
      const SizedBox(height: 16), 
      const BrightnessSelector(),
      const SizedBox(height: 16),
      Divider(),
      TextButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text("Sign Out"),
        onPressed: () {
          BlocProvider.of<AuthenticationBloc>(context)
              .add(AuthenticationSignOutEvent());
        },
      ),
    ],
  ),
),

      drawer: MainDrawer(),
    );
  }
}
