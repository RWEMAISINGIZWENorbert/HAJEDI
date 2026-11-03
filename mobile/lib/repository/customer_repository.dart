import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajedi/data/customer.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:http/http.dart' as http;

class CustomerRepository {
  final String _baseUrl = dotenv.env['API_URL']!;
   
  Future<List<Customer>> getAllCustomers() async {
    final url = Uri.parse('$_baseUrl/customer');

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
      final customersList = data['data'] as List;

      return customersList
          .map((json) => Customer.fromJson(json))
          .toList();
    }

    throw Exception(data['message'] ?? 'Failed to fetch customers');
  } 

  Future<Customer> createCustomer(Customer customer) async {
    final url = Uri.parse('$_baseUrl/customer');
    final token = await AuthUtils.getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'clientId': customer.clientId,
        'name': customer.name,
        'phone_number': customer.phoneNumber,
        'address': customer.address,
        'creditLimit': customer.creditLimit,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return Customer.fromJson(data['customer']);
    }

    throw Exception(data['message'] ?? 'Failed to create customer');
  }

  Future<Customer> updateCustomerByClientId(
    String clientId, {
    String? name,
    String? phoneNumber,
    String? address,
    double? creditLimit,
  }) async {
    final url = Uri.parse('$_baseUrl/customer/client/$clientId');

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
        if (creditLimit != null) 'creditLimit': creditLimit,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Customer.fromJson(data['customer']);
    }

    throw Exception(data['message'] ?? 'Failed to update customer');
  }

  Future<void> deleteCustomerByClientId(String clientId) async {
    final url = Uri.parse('$_baseUrl/customer/client/$clientId');

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

    throw Exception(data['message'] ?? 'Failed to delete customer');
  }

  Future<Map<String, dynamic>> getCustomerChanges({
    String? since,
  }) async {
    final query = since == null
        ? ''
        : '?since=${Uri.encodeQueryComponent(since)}';

    final url = Uri.parse(
      '$_baseUrl/customer/changes$query',
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
      data['message'] ?? 'Failed to fetch customer changes',
    );
  } 
} 