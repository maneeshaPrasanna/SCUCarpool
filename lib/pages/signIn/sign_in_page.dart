import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:santa_clara/pages/signIn/sign_in_header.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  /// 创建 Firestore 用户文档（如果尚未存在）
  Future<void> _createUserDocumentIfNeeded(auth.User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      print('create new user documnet：${user.uid}');
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'name': '',
        'phoneNumber': '',
        'avatarUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      print('user document exists：${user.uid}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "SCU Carpool",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 129, 30, 45),
      ),
      body: SignInScreen(
        headerBuilder: (context, constraints, shrinkOffset) => const SignInHeader(),
        providers: [EmailAuthProvider()],
        actions: [
          // createUserDocument when regisiter
          AuthStateChangeAction<UserCreated>((context, state) async {
            final user = auth.FirebaseAuth.instance.currentUser;
            if (user != null) {
              await _createUserDocumentIfNeeded(user);
            }
          }),

          // createUserDocument if there is no such documnet when sign in
          AuthStateChangeAction<SignedIn>((context, state) async {
            final user = auth.FirebaseAuth.instance.currentUser;
            if (user != null) {
              await _createUserDocumentIfNeeded(user);
            }
          }),
        ],
      ),
    );
  }
}
