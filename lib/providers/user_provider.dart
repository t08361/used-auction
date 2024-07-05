import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {

  String _id = '';
  String _username = '';
  String _email = '';
  String _nickname = '';
  String _location = '';
  int _age = 0;

  String get id => _id;
  String get username => _username;
  String get email => _email;
  String get nickname => _nickname;
  String get location => _location;
  int get age => _age;

  void setUser(Map<String, dynamic> userData) {
    _id = userData['id'];
    _username = userData['username'];
    _email = userData['email'];
    _nickname = userData['nickname'];
    _location = userData['location'];
    _age = userData['age'];
    notifyListeners();
  }

  void clearUser() {
    _id = '';
    _username = '';
    _email = '';
    _nickname = '';
    _location = '';
    _age = 0;
    notifyListeners();
  }

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}