import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_providers.dart';
import '../../../../core/utils/money_utils.dart';
import '../../data/holding_repository.dart';
import '../../domain/holding_model.dart';

/// StateNotifier managing the user's stock portfolio holdings.
///
/// Handles adding/updating holdings on BUY orders (weighted average cost calculation)
/// and reducing/removing holdings on SELL orders. Automatically persists state to [HoldingRepository].
class HoldingsNotifier extends StateNotifier<List<Holding>> {
  HoldingsNotifier(this._repository) : super([]) {
    _loadHoldings();
  }

  final HoldingRepository _repository;

  /// Loads saved holdings from storage on startup.
  void _loadHoldings() {
    state = _repository.getHoldings();
  }

  /// Gets the holding for a specific stock [symbol], or `null` if not held.
  Holding? getHolding(String symbol) {
    try {
      return state.firstWhere((h) => h.symbol == symbol);
    } catch (_) {
      return null;
    }
  }

  /// Adds a new holding or updates an existing holding after a BUY order execution.
  ///
  /// Formula for Average Cost:
  /// Uses [MoneyUtils.calculateWeightedAvgCost] to compute weighted average cost in paise:
  /// `(existingQty × existingAvgPaise + newQty × newPricePaise) ~/ totalQty`
  Future<void> addOrUpdateHolding({
    required String symbol,
    required int quantity,
    required int executionPricePaise,
  }) async {
    if (quantity <= 0 || executionPricePaise <= 0) return;

    final existingIndex = state.indexWhere((h) => h.symbol == symbol);

    List<Holding> updated;
    if (existingIndex >= 0) {
      // Existing holding found — compute weighted average cost
      final existing = state[existingIndex];
      final newQty = existing.quantity + quantity;
      final newAvgCostPaise = MoneyUtils.calculateWeightedAvgCost(
        existingQty: existing.quantity,
        existingAvgPaise: existing.avgCostPaise,
        newQty: quantity,
        newPricePaise: executionPricePaise,
      );

      final updatedHolding = existing.copyWith(
        quantity: newQty,
        avgCostPaise: newAvgCostPaise,
      );

      updated = List.from(state);
      updated[existingIndex] = updatedHolding;
    } else {
      // New holding — initial avg cost is execution price
      final newHolding = Holding(
        symbol: symbol,
        quantity: quantity,
        avgCostPaise: executionPricePaise,
      );
      updated = [...state, newHolding];
    }

    state = updated;
    await _repository.saveHoldings(updated);
  }

  /// Reduces holding quantity after a SELL order execution.
  ///
  /// Rule:
  /// If remaining quantity reaches zero (`newQty == 0`), the holding is REMOVED entirely!
  Future<void> reduceHolding({
    required String symbol,
    required int quantity,
  }) async {
    if (quantity <= 0) return;

    final existingIndex = state.indexWhere((h) => h.symbol == symbol);
    if (existingIndex < 0) return;

    final existing = state[existingIndex];
    final remainingQty = existing.quantity - quantity;

    List<Holding> updated = List.from(state);
    if (remainingQty <= 0) {
      // Quantity reduced to zero — remove holding completely from list
      updated.removeAt(existingIndex);
    } else {
      // Update with reduced quantity (average cost remains unchanged on sell)
      updated[existingIndex] = existing.copyWith(quantity: remainingQty);
    }

    state = updated;
    await _repository.saveHoldings(updated);
  }
}

/// Provider for user portfolio holdings.
final holdingsProvider =
    StateNotifierProvider<HoldingsNotifier, List<Holding>>((ref) {
  final repository = ref.watch(holdingRepositoryProvider);
  return HoldingsNotifier(repository);
});

/// Family provider getting a specific stock holding by symbol.
final holdingForSymbolProvider = Provider.family<Holding?, String>((ref, symbol) {
  final holdings = ref.watch(holdingsProvider);
  try {
    return holdings.firstWhere((h) => h.symbol == symbol);
  } catch (_) {
    return null;
  }
});
