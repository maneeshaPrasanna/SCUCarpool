import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:santa_clara/pages/signIn/sign_in_header.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});
  Future<void> saveUserFcmToken(String userId) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': fcmToken,
      });
      print("✅ FCM token saved: $fcmToken");
    }
  }

  /// 创建 Firestore 用户文档（如果尚未存在）
  Future<void> _createUserDocumentIfNeeded(auth.User user) async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      print('Create new user document: ${user.uid}');
      await userDocRef.set({
        'uid': user.uid,
        'email': user.email,
        'name': '',
        'phoneNumber': '',
        'avatarUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      print('User document exists: ${user.uid}');
    }
    // 👇 同时创建对应的 car 文档
    await _createCarDocument(user.uid);
  }

  /// 创建 Firestore 车辆文档（初始为空）
  Future<void> _createCarDocument(String uid) async {
    final carDocRef = FirebaseFirestore.instance.collection('cars').doc(uid);
    final carDoc = await carDocRef.get();

    if (!carDoc.exists) {
      print('Create new car document for uid: $uid');
      await carDocRef.set({
        'uid': uid,
        'maker': '',
        'model': '',
        'plate': '',
      });
    } else {
      print('Car document already exists for uid: $uid');
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
        headerBuilder: (context, constraints, shrinkOffset) =>
            const SignInHeader(),
        providers: [EmailAuthProvider()],
        actions: [
          // 注册时创建用户和车辆文档
          AuthStateChangeAction<UserCreated>((context, state) async {
            final user = auth.FirebaseAuth.instance.currentUser;
            if (user != null) {
              await _createUserDocumentIfNeeded(user);
            }
          }),

          // 登录时若文档不存在则创建
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
