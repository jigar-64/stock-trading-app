import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_providers.dart';
import '../../data/wallet_repository.dart';
import '../../domain/wallet_model.dart';

/// StateNotifier managing the user's wallet/margin cash balance.
///
/// Responsibilities:
/// 1. Stores cash balance in integer paise (minor units) to prevent float drift.
/// 2. Deducts cash on successful BUY order execution.
/// 3. Credits cash on successful SELL order execution.
/// 4. Automatically persists updated balance to [WalletRepository] (SharedPreferences).
class WalletNotifier extends StateNotifier<Wallet> {
  WalletNotifier(this._repository)
      : super(const Wallet.defaultBalance()) {
    _loadWallet();
  }

  final WalletRepository _repository;

  /// Loads persisted wallet balance from storage on initialization.
  void _loadWallet() {
    state = _repository.getWallet();
  }

  /// Deducts [paise] from wallet balance after a successful BUY order.
  ///
  /// Returns `true` if deduction succeeded, or `false` if balance was insufficient.
  Future<bool> deductBalance(int paise) async {
    if (paise <= 0) return false;
    if (state.balancePaise < paise) return false;

    final newBalance = state.balancePaise - paise;
    final updatedWallet = state.copyWith(balancePaise: newBalance);
    state = updatedWallet;

    await _repository.saveWallet(updatedWallet);
    return true;
  }

  /// Credits [paise] back to wallet balance after a successful SELL order.
  Future<void> creditBalance(int paise) async {
    if (paise <= 0) return;

    final newBalance = state.balancePaise + paise;
    final updatedWallet = state.copyWith(balancePaise: newBalance);
    state = updatedWallet;

    await _repository.saveWallet(updatedWallet);
  }

  /// Resets the wallet balance back to the default starting balance (₹1,00,000.00).
  Future<void> resetWallet() async {
    const defaultWallet = Wallet.defaultBalance();
    state = defaultWallet;
    await _repository.saveWallet(defaultWallet);
  }
}

/// Provider for the user's wallet state.
final walletProvider =
    StateNotifierProvider<WalletNotifier, Wallet>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return WalletNotifier(repository);
});

/// Fine-grained selector provider for the current wallet balance in paise.
final walletBalancePaiseProvider = Provider<int>((ref) {
  final wallet = ref.watch(walletProvider);
  return wallet.balancePaise;
});
