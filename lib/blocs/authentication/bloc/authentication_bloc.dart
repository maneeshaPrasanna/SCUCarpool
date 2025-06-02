import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:santa_clara/models/auth_user.dart';
import 'package:santa_clara/models/user.dart';
import 'package:santa_clara/repositories/authentication/authentication_repository.dart';
import 'package:santa_clara/services/mock/mock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitialState()) {
    on<AuthenticationEvent>((event, emit) {
      // TODO: implement event handler - this is the abstract class
    });
    on<AuthenticationInitializeEvent>((event, emit) {
      init(event, emit);
    });
    on<AuthenticationSignOutEvent>((event, emit) {
      signOut(event, emit);
    });
    on<AuthenticationSignInEvent>((event, emit) {
      // Implement manual sign in (away from FirebaseUIAuth package)
    });
    on<AuthenticationSignedInEvent>((event, emit) {
      emit(AuthenticationSignedInState(user: user!));
    });
    on<AuthenticationSignedOutEvent>((event, emit) {
      emit(AuthenticationNotSignedInState());
    });
    on<AuthenticationEmailVerificationRequest>((event, emit) {
      verifyEmail(event, emit);
    });
    on<AuthenticationEmailVerificationScreenEvent>((event, emit) {
      emit(AuthenticationEmailVerificationScreenState());
    });
    on<AuthenticationEmailVerificationCancelRequest>((event, emit) {
      emit(AuthenticationSignedInState(user: user!));
    });
  }
  late final AuthenticationRepository authenticationRepository;
  User? user;
  StreamSubscription<AuthUser>? authUserStreamSubscription;

  void init(AuthenticationInitializeEvent event, emit) {
    authenticationRepository = event.authenticationRepository;
    authUserStreamSubscription =
        authenticationRepository.authUserStream.listen((AuthUser authUser) {
      if (authUser.isNull || authUser.email == null || authUser.uid == null) {
        add(AuthenticationSignedOutEvent());
      } else {
        updateUser(authUser);
      }
    });
  }

  void signOut(event, emit) {
    emit(AuthenticationNotSignedInState());
    user = null;
    authenticationRepository.signOut();
  }

  void updateUser(AuthUser authUser) async {
    print("heyyyyaaa");
    final uid = authUser.uid;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      throw Exception('User not found in Firestore');
    }

    final userData = userDoc.data()!;

    user = User(
      email: authUser.email!,
      uid: authUser.uid!,
      name: authUser.displayName ?? "",

      emailVerified: authUser.emailVerified ?? false,
      imageUrl: userData['avatarUrl'] ?? '', // or a fallback if needed
      phoneNumber: userData['phoneNumber'] ?? '',

      createdAt: DateTime.now(),
    );

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': fcmToken,
      });
      print("✅ FCM Token saved to Firestore: $fcmToken");
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': newToken,
      });
      print("🔁 FCM Token refreshed and updated: $newToken");
    });
    print("jiii ${authUser.displayName}");
    if (user!.emailVerified) {
      add(AuthenticationSignedInEvent());
    } else {
      add(AuthenticationEmailVerificationScreenEvent());
    }
  }

  void verifyEmail(event, emit) {
    emit(AuthenticationVerifyEmailState());
    authenticationRepository.verifyEmail(user?.email);
  }

  @override
  Future<void> close() {
    authUserStreamSubscription?.cancel();
    return super.close();
  }
}
