import 'package:shared_preferences/shared_preferences.dart';

class SyncMetadata {
  static const _usersCursorKey = 'users_sync_cursor';
  static const _productsCursorKey = 'products_sync_cursor';
  static const _salesCursorKey = 'sales_sync_cursor';
  static const _purchasesCursorKey = 'purchases_sync_cursor';
  static const _expensesCursorKey = 'expenses_sync_cursor';
  static const _customerCursorKey = 'customers_sync_cursor';
  static const _supplierCursorKey = 'suppliers_sync_cursor';

  static Future<String?> getUsersCursor() async {
    final preferences =
        await SharedPreferences.getInstance();

    return preferences.getString(_usersCursorKey);
  }

  static Future<void> saveUsersCursor(
    String cursor,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.setString(
      _usersCursorKey,
      cursor,
    );
  }

  static Future<String?> getProductsCursor() async {
    final preferences =
        await SharedPreferences.getInstance();

    return preferences.getString(_productsCursorKey);
  }

  static Future<void> saveProductsCursor(
    String cursor,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.setString(
      _productsCursorKey,
      cursor,
    );
  }

  static Future<String?> getSalesCursor() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_salesCursorKey);
  }

  static Future<void> saveSalesCursor(String cursor) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_salesCursorKey, cursor);
  }

  static Future<String?> getPurchasesCursor() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_purchasesCursorKey);
  }

  static Future<void> savePurchasesCursor(String cursor) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_purchasesCursorKey, cursor);
  }

  static Future<String?> getExpensesCursor() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_expensesCursorKey);
  }

  static Future<void> saveExpensesCursor(String cursor) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_expensesCursorKey, cursor);
  }

  static Future<String?> getCustomersCursor() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_customerCursorKey);
}

static Future<void> saveCustomersCursor(String cursor) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_customerCursorKey, cursor);
}

static Future<String?> getSuppliersCursor() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_supplierCursorKey);
}

static Future<void> saveSuppliersCursor(String cursor) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_supplierCursorKey, cursor);
}

  static Future<void> clear() async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(_usersCursorKey);
    await preferences.remove(_productsCursorKey);
    await preferences.remove(_salesCursorKey);
    await preferences.remove(_purchasesCursorKey);
    await preferences.remove(_expensesCursorKey);
    await preferences.remove(_customerCursorKey);
    await preferences.remove(_supplierCursorKey);
  }
}