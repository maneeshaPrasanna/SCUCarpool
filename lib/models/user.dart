// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:santa_clara/services/mock/mock.dart';

class User {
  final String name;
  final String email;
  final String imageUrl;
  final String uid;
  final bool emailVerified;
  final String? phoneNumber;
  final createdAt;

  User({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.uid,
    required this.emailVerified,
    required this.phoneNumber,
    required this.createdAt,
  });

  User copyWith({
    String? name,
    String? email,
    String? imageUrl,
    String? uid,
    bool? emailVerified,
    String? phoneNumber,
    createdAt,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      uid: uid ?? this.uid,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'uid': uid,
      'emailVerified': emailVerified,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] as String,
      email: map['email'] as String,
      imageUrl: map['imageUrl'] as String,
      uid: map['uid'] as String,
      emailVerified: map['emailVerified'] as bool,
      phoneNumber: map['phoneNumber'] as String?,
      createdAt: map['createdAt'],
    );
  }

  //String toJson() => json.encode(toMap());
  Map<String, dynamic> toJson() => toMap();

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  static User createMockUser() {
    return User(
      name: Mock.displayName(),
      email: Mock.email(),
      imageUrl: Mock.imageUrl(),
      uid: Mock.uid(),
      emailVerified: true,
      phoneNumber: '1234567890',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  String toString() {
    return 'User(displayName: $name,  email: $email, imageUrl: $imageUrl, uid: $uid, verified: $emailVerified, phoneNumber: $phoneNumber, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.email == email &&
        other.imageUrl == imageUrl &&
        other.uid == uid &&
        other.emailVerified == emailVerified;
  }

  @override
  int get hashCode {
    return name.hashCode ^ email.hashCode ^ imageUrl.hashCode ^ uid.hashCode;
    emailVerified.hashCode;
    phoneNumber.hashCode ^ createdAt.hashCode;
  }
}
