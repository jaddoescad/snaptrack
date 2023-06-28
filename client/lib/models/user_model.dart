import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  String id;
  String email;

  UserModel({
    required this.id,
    required this.email,
  });

  void updateUser(String newId, String newEmail) {
    id = newId;
    email = newEmail;
    notifyListeners();
  }
}