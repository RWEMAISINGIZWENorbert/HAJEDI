import 'dart:convert';

import 'package:hajedi/data/auth_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {

  static void saveToken(String token)  async {
     SharedPreferences prfs  = await SharedPreferences.getInstance();
     await prfs.setString('token', token);
  }

  static Future<String?> getToken() async {
    SharedPreferences prfs = await SharedPreferences.getInstance();
    return prfs.getString('token');
  }

  static Future<void> saveUser(AuthData authData) async {
    SharedPreferences prfs = await SharedPreferences.getInstance();
    await prfs.setString('user_data', jsonEncode(authData.toJson()));
  }

  static Future<AuthData?> readUser() async {
    SharedPreferences prfs = await SharedPreferences.getInstance();
    final userData = prfs.getString('user_data');
    if (userData != null) {
      return AuthData.fromJson(jsonDecode(userData));
    }
    return null;
   } 

  static Future<void> clearAuthData() async {
     final preferences = await SharedPreferences.getInstance();

     await preferences.remove('token');
     await preferences.remove('user_data');
  } 

  static Future<bool> isAuthenticated() async {
  final preferences = await SharedPreferences.getInstance();

  final token = preferences.getString('token');
  final userData = preferences.getString('user_data');

  if (token == null ||
      token.trim().isEmpty ||
      userData == null ||
      userData.trim().isEmpty) {
    return false;
  }

  return true;
}
 
}