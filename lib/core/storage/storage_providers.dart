import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/order/data/order_repository.dart';
import '../../features/portfolio/data/holding_repository.dart';
import '../../features/wallet/data/wallet_repository.dart';
import '../../features/watchlist/data/watchlist_repository.dart';

/// Provider for the [SharedPreferences] instance.
///
/// This provider MUST be overridden in `main.dart` at app startup
/// after initializing SharedPreferences asynchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

/// Provider for [WatchlistRepository].
final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WatchlistRepository(prefs);
});

/// Provider for [HoldingRepository].
final holdingRepositoryProvider = Provider<HoldingRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HoldingRepository(prefs);
});

/// Provider for [WalletRepository].
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WalletRepository(prefs);
});

/// Provider for [OrderRepository].
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OrderRepository(prefs);
});
