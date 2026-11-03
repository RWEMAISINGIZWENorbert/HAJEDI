import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajedi/data/purchase.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:http/http.dart' as http;

class PurchaseRepository {
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

  Future<Purchase> createPurchase({
    required String clientId,
    String? supplierClientId,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse('$_baseUrl/transaction/purchases');
    final headers = await _headers();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'clientId': clientId,
        'supplierClientId': supplierClientId,
        'paymentMethod': paymentMethod,
        'items': items,
      }),
    );

    print('Create Purchase Response: ${response.body}');

    final data = await _decodeResponse(response);

    if (response.statusCode == 201) {
      return Purchase.fromJson(Map<String, dynamic>.from(data['data'] as Map));
    }

    throw Exception(data['message'] ?? 'Failed to create purchase');
  }

  Future<Map<String, dynamic>> getPurchaseChanges({String? since}) async {
    final query = since == null || since.isEmpty
        ? ''
        : '?since=${Uri.encodeQueryComponent(since)}';

    final url = Uri.parse('$_baseUrl/transaction/purchases/changes$query');
    final headers = await _headers();

    final response = await http.get(url, headers: headers);

    final data = await _decodeResponse(response);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Failed to fetch purchase changes');
  }

  Future<void> voidPurchase(String clientId, {String? voidReason}) async {
    final url = Uri.parse('$_baseUrl/transaction/purchases/$clientId/void');
    final headers = await _headers();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'voidReason': voidReason}),
    );

    if (response.statusCode != 200) {
      final data = await _decodeResponse(response);
      throw Exception(data['message'] ?? 'Failed to void purchase');
    }
  }
}
