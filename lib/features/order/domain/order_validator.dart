import '../../../core/utils/money_utils.dart';

/// Pure domain validation functions for stock order placement (Buy & Sell Ticket).
///
/// Principles:
/// 1. Pure Functions: Zero side-effects, zero dependencies on UI or global state.
/// 2. Clear Inline Feedback: Returns human-readable error strings or `null` if valid.
/// 3. Money Precision: All financial comparisons use integer paise to prevent floating-point errors.
class OrderValidator {
  OrderValidator._();

  /// Validates the quantity input string entered by the user.
  ///
  /// Rejects:
  /// - Empty or null input
  /// - Non-numeric characters
  /// - Fractional/decimal quantities (e.g. "1.5")
  /// - Zero or negative quantities (e.g. "0", "-5")
  ///
  /// Returns `null` if the quantity is a valid positive integer.
  static String? validateQuantity(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Quantity is required';
    }

    final trimmed = input.trim();

    // Check for fractional/decimal values (e.g. "1.5" or "10.0")
    if (trimmed.contains('.') || trimmed.contains(',')) {
      return 'Fractional shares are not supported. Enter a whole number.';
    }

    // Parse integer
    final qty = int.tryParse(trimmed);
    if (qty == null) {
      return 'Enter a valid numeric quantity';
    }

    if (qty <= 0) {
      return 'Quantity must be at least 1 share';
    }

    return null;
  }

  /// Validates whether the user has sufficient wallet balance for a BUY order.
  ///
  /// Param [orderValuePaise]: Projected total order value (quantity × current LTP) in paise.
  /// Param [walletBalancePaise]: Available wallet balance in paise.
  ///
  /// Returns an error message if the order value exceeds available balance, or `null` if valid.
  static String? validateBuyBalance({
    required int orderValuePaise,
    required int walletBalancePaise,
  }) {
    if (orderValuePaise <= 0) {
      return 'Invalid order value';
    }

    if (orderValuePaise > walletBalancePaise) {
      final reqStr = MoneyUtils.paiseToCurrency(orderValuePaise);
      final availStr = MoneyUtils.paiseToCurrency(walletBalancePaise);
      return 'Insufficient margin balance. Required: $reqStr, Available: $availStr';
    }

    return null;
  }

  /// Validates whether the user holds enough shares for a SELL order.
  ///
  /// Param [sellQuantity]: Number of shares the user wants to sell.
  /// Param [heldQuantity]: Number of shares currently held in portfolio.
  ///
  /// Returns an error message if selling more than held, or `null` if valid.
  static String? validateSellQuantity({
    required int sellQuantity,
    required int heldQuantity,
  }) {
    if (sellQuantity <= 0) {
      return 'Quantity must be at least 1 share';
    }

    if (heldQuantity <= 0) {
      return 'You do not own any shares of this stock';
    }

    if (sellQuantity > heldQuantity) {
      return 'Exceeds portfolio holdings. You hold $heldQuantity share${heldQuantity > 1 ? 's' : ''}';
    }

    return null;
  }
}
