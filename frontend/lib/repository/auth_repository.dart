import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajedi/data/auth_data.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String _baseUrl = dotenv.env['API_URL']!;

  Future<AuthData> login({
    required String name,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/login');
      
   try{
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final userJson = Map<String, dynamic>.from(
        data['user'] as Map,
      );

      final authData = AuthData.fromJson(userJson);
      final accessToken = data['tokens']['accessToken'] as String;

      AuthUtils.saveToken(accessToken);
      AuthUtils.saveUser(authData);

      return authData;
    }

    throw Exception(data['message'] ?? 'Login failed');
     }catch (e) {
      throw Exception('Login failed');
     }
  }

}