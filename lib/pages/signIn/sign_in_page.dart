import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:santa_clara/pages/signIn/sign_in_header.dart';
import 'package:santa_clara/services/mock/mock.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "SCU Carpool",
          style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold,fontSize: 24),
        ),
        backgroundColor: const Color.fromARGB(255, 129, 30, 45),
      ),
      body: SignInScreen(
        headerBuilder: (context, constraints, shrinkOffset) => const SignInHeader(),
        providers: [EmailAuthProvider()],
        actions: [
          AuthStateChangeAction<SignedIn>((context, state) {}),
        ],
      ),
    );
  }
}
