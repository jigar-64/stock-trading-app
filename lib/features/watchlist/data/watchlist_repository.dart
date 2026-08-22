import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/watchlist_model.dart';

/// Repository for persisting and retrieving user watchlists.
///
/// Watchlists are serialized as JSON strings in [SharedPreferences].
/// If no watchlists exist on first launch, a default "Main Watchlist"
/// populated with top stocks is automatically created.
class WatchlistRepository {
  WatchlistRepository(this._prefs);

  final SharedPreferences _prefs;
  static const String _key = 'user_watchlists';

  /// Loads all saved watchlists from persistent storage.
  ///
  /// If no watchlists are saved yet, initializes and returns a default
  /// watchlist containing top stocks.
  List<Watchlist> getWatchlists() {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) {
      final defaultWatchlists = _createDefaultWatchlists();
      saveWatchlists(defaultWatchlists);
      return defaultWatchlists;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => Watchlist.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // If parsing fails due to corrupted data, fall back to defaults
      final defaultWatchlists = _createDefaultWatchlists();
      saveWatchlists(defaultWatchlists);
      return defaultWatchlists;
    }
  }

  /// Persists the list of watchlists to storage.
  Future<bool> saveWatchlists(List<Watchlist> watchlists) async {
    final jsonList = watchlists.map((w) => w.toJson()).toList();
    return _prefs.setString(_key, jsonEncode(jsonList));
  }

  /// Creates default initial watchlists for a fresh installation.
  List<Watchlist> _createDefaultWatchlists() {
    return [
      Watchlist(
        id: 'default-main-watchlist',
        name: 'Main Watchlist',
        symbols: [
          'RELIANCE',
          'TCS',
          'INFY',
          'HDFCBANK',
          'ICICIBANK',
        ],
      ),
      Watchlist(
        id: 'default-banking-watchlist',
        name: 'Banking & Financials',
        symbols: [
          'HDFCBANK',
          'ICICIBANK',
          'SBIN',
          'AXISBANK',
        ],
      ),
    ];
  }
}
