import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_providers.dart';
import '../../data/watchlist_repository.dart';
import '../../domain/watchlist_model.dart';

/// StateNotifier managing the user's collection of watchlists.
///
/// Handles CRUD operations for watchlists (create, rename, delete)
/// and stock manipulation within a watchlist (add, remove, reorder).
/// Automatically persists state changes to [WatchlistRepository] (SharedPreferences).
class WatchlistsNotifier extends StateNotifier<List<Watchlist>> {
  WatchlistsNotifier(this._repository) : super([]) {
    _loadWatchlists();
  }

  final WatchlistRepository _repository;

  /// Loads persisted watchlists on initialization.
  void _loadWatchlists() {
    state = _repository.getWatchlists();
  }

  /// Creates a new watchlist with the given [name] and persists it.
  Future<void> createWatchlist(String name) async {
    if (name.trim().isEmpty) return;

    final newWatchlist = Watchlist(name: name.trim());
    final updated = [...state, newWatchlist];
    state = updated;
    await _repository.saveWatchlists(updated);
  }

  /// Renames an existing watchlist by [id] and persists the change.
  Future<void> renameWatchlist(String id, String newName) async {
    if (newName.trim().isEmpty) return;

    final updated = state.map((w) {
      if (w.id == id) {
        return w.copyWith(name: newName.trim());
      }
      return w;
    }).toList();

    state = updated;
    await _repository.saveWatchlists(updated);
  }

  /// Deletes a watchlist by [id] and persists the updated list.
  Future<void> deleteWatchlist(String id) async {
    final updated = state.where((w) => w.id != id).toList();
    state = updated;
    await _repository.saveWatchlists(updated);
  }

  /// Adds a stock [symbol] to the specified watchlist if not already present.
  Future<void> addStock(String watchlistId, String symbol) async {
    final updated = state.map((w) {
      if (w.id == watchlistId) {
        if (!w.symbols.contains(symbol)) {
          final newSymbols = [...w.symbols, symbol];
          return w.copyWith(symbols: newSymbols);
        }
      }
      return w;
    }).toList();

    state = updated;
    await _repository.saveWatchlists(updated);
  }

  /// Removes a stock [symbol] from the specified watchlist.
  Future<void> removeStock(String watchlistId, String symbol) async {
    final updated = state.map((w) {
      if (w.id == watchlistId) {
        final newSymbols = w.symbols.where((s) => s != symbol).toList();
        return w.copyWith(symbols: newSymbols);
      }
      return w;
    }).toList();

    state = updated;
    await _repository.saveWatchlists(updated);
  }

  /// Reorders stocks within a watchlist via drag-and-drop.
  ///
  /// Crucial Architecture Guarantee:
  /// Moving symbols in [symbols] alters the array index, but NOT the symbol strings.
  /// Because UI rows bind to prices via symbol string identity (`singleStockPriceProvider(symbol)`),
  /// reordering CANNOT cause stale price ticks to show up on the wrong row!
  Future<void> reorderStock(
    String watchlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final updated = state.map((w) {
      if (w.id == watchlistId) {
        final symbols = List<String>.from(w.symbols);
        // Adjust index when moving downwards in ReorderableListView
        var targetIndex = newIndex;
        if (oldIndex < targetIndex) {
          targetIndex -= 1;
        }
        final movedSymbol = symbols.removeAt(oldIndex);
        symbols.insert(targetIndex, movedSymbol);
        return w.copyWith(symbols: symbols);
      }
      return w;
    }).toList();

    state = updated;
    await _repository.saveWatchlists(updated);
  }
}

/// Provider for the list of user watchlists.
final watchlistsProvider =
    StateNotifierProvider<WatchlistsNotifier, List<Watchlist>>((ref) {
  final repository = ref.watch(watchlistRepositoryProvider);
  return WatchlistsNotifier(repository);
});

/// Provider for tracking the currently selected watchlist tab index.
final activeWatchlistIndexProvider = StateProvider<int>((ref) => 0);
