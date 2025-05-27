// lib/data/repositories/user_repository.dart
import 'dart:convert';
import 'package:medical_app/data/models/role.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medical_app/data/models/user.dart';

class UserRepository {
  static const String _userKey = 'current_user';

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString != null) {
      return User.fromJson(jsonDecode(userString));
    }

    return null;
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
