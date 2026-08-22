import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/order_model.dart';

/// Repository for persisting and retrieving order history.
class OrderRepository {
  OrderRepository(this._prefs);

  final SharedPreferences _prefs;
  static const String _key = 'user_order_history';

  /// Loads all executed orders from storage.
  List<Order> getOrders() {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists the full order history to storage.
  Future<bool> saveOrders(List<Order> orders) async {
    final jsonList = orders.map((o) => o.toJson()).toList();
    return _prefs.setString(_key, jsonEncode(jsonList));
  }

  /// Appends a new executed order to history and persists it.
  Future<bool> recordOrder(Order order) async {
    final currentOrders = getOrders();
    currentOrders.insert(0, order); // Newest orders first
    return saveOrders(currentOrders);
  }
}
