import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajedi/data/expense.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:http/http.dart' as http;

class ExpenseRepository {
  final String _baseUrl = dotenv.env['API_URL']!;

  Future<Map<String, String>> _headers() async {
    final token = await AuthUtils.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _decodeResponse(http.Response response) async {
    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Invalid server response');
  }

  Future<Expense> createExpense({
    required String clientId,
    required String description,
    required double amount,
    required String category,
    String paymentMethod = 'cash',
  }) async {
    final url = Uri.parse('$_baseUrl/transaction/expenses');
    final headers = await _headers();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'clientId': clientId,
        'description': description,
        'amount': amount,
        'category': category,
        'paymentMethod': paymentMethod,
      }),
    );

    print('Create Expense Response: ${response.body}');

    final data = await _decodeResponse(response);

    if (response.statusCode == 201) {
      return Expense.fromJson(Map<String, dynamic>.from(data['data'] as Map));
    }

    throw Exception(data['message'] ?? 'Failed to create expense');
  }

  Future<Map<String, dynamic>> getExpenseChanges({String? since}) async {
    final query = since == null || since.isEmpty
        ? ''
        : '?since=${Uri.encodeQueryComponent(since)}';

    final url = Uri.parse('$_baseUrl/transaction/expenses/changes$query');
    final headers = await _headers();

    final response = await http.get(url, headers: headers);

    final data = await _decodeResponse(response);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to fetch expense changes');
  }

  Future<void> voidExpense(String clientId, {String? voidReason}) async {
    final url = Uri.parse('$_baseUrl/transaction/expenses/$clientId/void');
    final headers = await _headers();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'voidReason': voidReason}),
    );

    if (response.statusCode != 200) {
      final data = await _decodeResponse(response);
      throw Exception(data['message'] ?? 'Failed to void expense');
    }
  }
}
