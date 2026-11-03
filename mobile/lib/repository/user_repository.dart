

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajedi/data/user.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  final String _baseUrl = dotenv.env['API_URL']!;
   
  Future<List<User>> getAllUsers() async {
    final url = Uri.parse('$_baseUrl/auth/users');

    final token = await AuthUtils.getToken();

    final response = await http.get(
      url,
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final usersList = data['data'] as List;

      return usersList
          .map((json) => User.fromJson(json))
          .toList();
    }

    throw Exception(data['message'] ?? 'Failed to fetch users');
  } 

  Future<User> registerUser(User user) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    final token = await AuthUtils.getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'clientId': user.clientId,
        'name': user.name,
        'role': user.role,
        'password': user.password,
      }),
    );

    print('Register User Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return User.fromJson(data['user']);
    }

    throw Exception(data['message'] ?? 'Registration failed');
  }

  Future<User> updateUser(
    String id, {
    String? name,
    String? role,
    String? password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/users/$id');

    final token = await AuthUtils.getToken();

    try{
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': ?name,
        'role': ?role,
        if (password != null && password.isNotEmpty) 'password': password,
      }),
    );
     print('Update User Response: ${response.body}');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return User.fromJson(data['user']);
    }
    print('Error updating user: ${response.body}');
    throw Exception(data['message'] ?? 'Failed to update user');
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> removeUser(String id) async {
    final url = Uri.parse('$_baseUrl/auth/users/$id');

    final token = await AuthUtils.getToken();

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

     print('Remove User Response: ${response.statusCode} - ${response.body}');
      
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception(data['message'] ?? 'Failed to remove user');
  }

  Future<Map<String, dynamic>> getUserChanges({
    String? since,
  }) async {
    final query = since == null
        ? ''
        : '?since=${Uri.encodeQueryComponent(since)}';

    final url = Uri.parse(
      '$_baseUrl/auth/users/changes$query',
    );

    final token = await AuthUtils.getToken();

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Failed to fetch user changes',
    );
  } 

} 
