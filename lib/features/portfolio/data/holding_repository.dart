import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/holding_model.dart';

/// Repository for persisting and retrieving user stock holdings.
///
/// Holdings store business ownership data (quantity and average cost).
/// Live LTP and P&L are derived dynamically from the market feed, never stored.
class HoldingRepository {
  HoldingRepository(this._prefs);

  final SharedPreferences _prefs;
  static const String _key = 'user_holdings';

  /// Loads all saved holdings from persistent storage.
  List<Holding> getHoldings() {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => Holding.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists the complete list of holdings to storage.
  Future<bool> saveHoldings(List<Holding> holdings) async {
    final jsonList = holdings.map((h) => h.toJson()).toList();
    return _prefs.setString(_key, jsonEncode(jsonList));
  }
}
