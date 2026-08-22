import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/stock_constants.dart';
import '../domain/wallet_model.dart';

/// Repository for persisting and retrieving the user's cash/margin balance.
///
/// Balance is stored as integer paise (minor units).
class WalletRepository {
  WalletRepository(this._prefs);

  final SharedPreferences _prefs;
  static const String _key = 'user_wallet_balance_paise';

  /// Gets the current wallet balance from storage.
  ///
  /// Defaults to ₹1,00,000.00 (10,000,000 paise) for fresh installs.
  Wallet getWallet() {
    final balancePaise = _prefs.getInt(_key) ??
        StockConstants.defaultWalletBalancePaise;
    return Wallet(balancePaise: balancePaise);
  }

  /// Persists the wallet balance to storage.
  Future<bool> saveWallet(Wallet wallet) async {
    return _prefs.setInt(_key, wallet.balancePaise);
  }
}
