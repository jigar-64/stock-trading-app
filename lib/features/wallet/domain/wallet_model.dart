import '../../../core/constants/stock_constants.dart';

/// The user's wallet/margin balance for simulated trading.
///
/// Balance is stored in paise (integer minor units).
class Wallet {
  const Wallet({required this.balancePaise});

  /// Creates a wallet with the default starting balance.
  const Wallet.defaultBalance()
      : balancePaise = StockConstants.defaultWalletBalancePaise;

  /// Current balance in paise.
  final int balancePaise;

  /// Creates a copy with the given balance.
  Wallet copyWith({int? balancePaise}) {
    return Wallet(balancePaise: balancePaise ?? this.balancePaise);
  }

  @override
  String toString() => 'Wallet(balance: $balancePaise paise)';
}
