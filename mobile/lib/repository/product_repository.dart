import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
  final String _baseUrl = dotenv.env['API_URL']!;

  Future<Map<String, String>> _headers() async {
    final token = await AuthUtils.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _decodeResponse(
    http.Response response,
  ) async {
    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('Invalid server response');
  }

  Future<Product> registerProduct(Product product) async {
    final url = Uri.parse('$_baseUrl/product/');
    final headers = await _headers();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'clientId': product.clientId,
        'name': product.name,
        'productType': product.productType,
        'purchaseMethod': product.purchaseMethod,
        'saleMethod': product.saleMethod,
        'purchaseCost': product.purchaseCost,
        'sellingPrice': product.sellingPrice,
        'unitsPerPackage': product.unitsPerPackage,
        'quantityInStock': product.quantityInStock,
      }),
    );

    print("Response: ${response.body}");

    final data = await _decodeResponse(response);

    if (response.statusCode == 201) {
      return Product.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    }

    throw Exception(
      data['message'] ?? 'Failed to create product',
    );
  }

  Future<List<Product>> getAllProducts() async {
    final url = Uri.parse('$_baseUrl/product/');
    final headers = await _headers();

    final response = await http.get(
      url,
      headers: headers,
    );

    final data = await _decodeResponse(response);

    if (response.statusCode == 200) {
      final products = data['data'] as List<dynamic>;

      return products
          .map(
            (product) => Product.fromJson(
              Map<String, dynamic>.from(product as Map),
            ),
          )
          .toList();
    }

    throw Exception(
      data['message'] ?? 'Failed to fetch products',
    );
  }

  Future<Product> getProductByClientId(
    String clientId,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/product/client/$clientId',
    );
    final headers = await _headers();

    final response = await http.get(
      url,
      headers: headers,
    );

    final data = await _decodeResponse(response);

    if (response.statusCode == 200) {
      return Product.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    }

    throw Exception(
      data['message'] ?? 'Failed to fetch product',
    );
  }

  Future<Product> updateProduct(
    String clientId, {
    String? name,
    String? productType,
    String? purchaseMethod,
    String? saleMethod,
    double? purchaseCost,
    double? sellingPrice,
    int? unitsPerPackage,
    int? quantityInStock,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/product/client/$clientId',
    );
    final headers = await _headers();

    final body = <String, dynamic>{};

    if (name != null && name.trim().isNotEmpty) {
      body['name'] = name.trim();
    }

    if (productType != null && productType.isNotEmpty) {
      body['productType'] = productType;
    }

    if (purchaseMethod != null && purchaseMethod.isNotEmpty) {
      body['purchaseMethod'] = purchaseMethod;
    }

    if (saleMethod != null && saleMethod.isNotEmpty) {
      body['saleMethod'] = saleMethod;
    }

    if (purchaseCost != null) {
      body['purchaseCost'] = purchaseCost;
    }

    if (sellingPrice != null) {
      body['sellingPrice'] = sellingPrice;
    }

    if (unitsPerPackage != null) {
      body['unitsPerPackage'] = unitsPerPackage;
    }

    if (quantityInStock != null) {
      body['quantityInStock'] = quantityInStock;
    }

    if (body.isEmpty) {
      throw Exception('At least one field is required to update');
    }

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    final data = await _decodeResponse(response);

    if (response.statusCode == 200) {
      return Product.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    }

    throw Exception(
      data['message'] ?? 'Failed to update product',
    );
  }

  Future<void> removeProduct(String clientId) async {
    final url = Uri.parse(
      '$_baseUrl/product/client/$clientId',
    );
    final headers = await _headers();

    final response = await http.delete(
      url,
      headers: headers,
    );

    final data = await _decodeResponse(response);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(
      data['message'] ?? 'Failed to remove product',
    );
  }

  Future<Map<String, dynamic>> getProductChanges({
    String? since,
  }) async {
    final query = since == null || since.isEmpty
        ? ''
        : '?since=${Uri.encodeQueryComponent(since)}';

    final url = Uri.parse(
      '$_baseUrl/product/changes$query',
    );
    final headers = await _headers();

    final response = await http.get(
      url,
      headers: headers,
    );

    final data = await _decodeResponse(response);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Failed to fetch product changes',
    );
  }
}