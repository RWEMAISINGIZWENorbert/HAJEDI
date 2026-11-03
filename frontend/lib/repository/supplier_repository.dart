import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajedi/data/supplier.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:http/http.dart' as http;

class SupplierRepository {
  final String _baseUrl = dotenv.env['API_URL']!;
   
  Future<List<Supplier>> getAllSuppliers() async {
    final url = Uri.parse('$_baseUrl/supplier');

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
      final suppliersList = data['data'] as List;

      return suppliersList
          .map((json) => Supplier.fromJson(json))
          .toList();
    }

    throw Exception(data['message'] ?? 'Failed to fetch suppliers');
  } 

  Future<Supplier> createSupplier(Supplier supplier) async {
    final url = Uri.parse('$_baseUrl/supplier');
    final token = await AuthUtils.getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'clientId': supplier.clientId,
        'name': supplier.name,
        'phone_number': supplier.phoneNumber,
        'address': supplier.address,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return Supplier.fromJson(data['supplier']);
    }

    throw Exception(data['message'] ?? 'Failed to create supplier');
  }

  Future<Supplier> updateSupplierByClientId(
    String clientId, {
    String? name,
    String? phoneNumber,
    String? address,
  }) async {
    final url = Uri.parse('$_baseUrl/supplier/client/$clientId');

    final token = await AuthUtils.getToken();

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (name != null) 'name': name,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (address != null) 'address': address,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Supplier.fromJson(data['supplier']);
    }

    throw Exception(data['message'] ?? 'Failed to update supplier');
  }

  Future<void> deleteSupplierByClientId(String clientId) async {
    final url = Uri.parse('$_baseUrl/supplier/client/$clientId');

    final token = await AuthUtils.getToken();

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(data['message'] ?? 'Failed to delete supplier');
  }

  Future<Map<String, dynamic>> getSupplierChanges({
    String? since,
  }) async {
    final query = since == null
        ? ''
        : '?since=${Uri.encodeQueryComponent(since)}';

    final url = Uri.parse(
      '$_baseUrl/supplier/changes$query',
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
      data['message'] ?? 'Failed to fetch supplier changes',
    );
  } 
} 