import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {

  String? _role;
  String? _username;

  String? get role => _role;
  String? get username => _username;

  bool get isLogin => _role != null;

  // LOGIN TANPA VALIDASI
  bool login(String username, String password) {

    // langsung simpan username
    _username = username;

    // role default
    _role = "user";

    // refresh provider
    notifyListeners();

    // selalu berhasil login
    return true;
  }

  // LOGOUT
  void logout() {
    _role = null;
    _username = null;
    notifyListeners();
  }
}