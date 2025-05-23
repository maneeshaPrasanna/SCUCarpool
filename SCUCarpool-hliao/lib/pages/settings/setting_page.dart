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
        title: Text(
          title,
          style: const TextStyle(color:Colors.white, fontWeight: FontWeight.bold,fontSize: 24),
        ),
        backgroundColor: const Color.fromARGB(255, 129, 30, 45),
      ),
      body:  Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
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
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const BrightnessSelector(),
      ]),
      drawer: const MainDrawer(),
    );
  }
}
