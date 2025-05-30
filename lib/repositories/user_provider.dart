import 'package:flutter/material.dart';
import 'package:santa_clara/models/user.dart' as modelUser;

class UserProvider extends ChangeNotifier {
  modelUser.User? _user;

  modelUser.User? get user => _user;

  void setUser(modelUser.User user) {
    _user = user;
    notifyListeners();
  }
}
