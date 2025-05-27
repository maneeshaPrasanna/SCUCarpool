import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:santa_clara/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:santa_clara/models/user.dart' as modelUser;

import 'package:santa_clara/pages/signIn/sign_in_header.dart';
import 'package:santa_clara/repositories/user_provider.dart';

modelUser.User? userModel;

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  /// 创建 Firestore 用户文档（如果尚未存在）
  Future<void> _createUserDocumentIfNeeded(
      auth.User user, BuildContext context) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      print('create new user documnet：${user.uid}');
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? '',
        'phoneNumber': user.phoneNumber ?? '',
        'avatarUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      print('user document exists：${user.uid}');
    }
    final fetchedDoc = await docRef.get();
    final data = fetchedDoc.data()!;
    userModel = modelUser.User(
      email: user.email!,
      uid: user.uid,
      name: user.displayName ?? "",
      imageUrl: user.photoURL ?? "",
      emailVerified: user.emailVerified ?? false,
      phoneNumber: user.phoneNumber ?? "",
      createdAt: DateTime.now(),
    );

    Provider.of<UserProvider>(context, listen: false).setUser(userModel!);
    context.read<AuthenticationBloc>().add(
          AuthenticationSignedInEvent(),
        );
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
        headerBuilder: (context, constraints, shrinkOffset) =>
            const SignInHeader(),
        providers: [EmailAuthProvider()],
        actions: [
          // createUserDocument when regisiter
          AuthStateChangeAction<UserCreated>((context, state) async {
            final user = auth.FirebaseAuth.instance.currentUser;
            if (user != null) {
              await _createUserDocumentIfNeeded(user, context);
            }
          }),

          // createUserDocument if there is no such documnet when sign in
          AuthStateChangeAction<SignedIn>((context, state) async {
            final user = auth.FirebaseAuth.instance.currentUser;
            if (user != null) {
              await _createUserDocumentIfNeeded(user, context);
            }
          }),
        ],
      ),
    );
  }
}
