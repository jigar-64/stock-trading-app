/// Utility functions for money formatting and calculations.
///
/// All monetary values in this app are stored as integer paise (minor units)
/// to completely avoid floating-point drift.
/// Example: ₹2,845.35 is stored as 284535 (int).
class MoneyUtils {
  MoneyUtils._();

  /// Formats paise as a currency string with the ₹ symbol.
  ///
  /// Example: 284535 → "₹2,845.35"
  /// Example: -284535 → "-₹2,845.35"
  static String paiseToCurrency(int paise) {
    final isNegative = paise < 0;
    final absPaise = paise.abs();
    final rupees = absPaise ~/ 100;
    final remainingPaise = absPaise % 100;
    final formattedRupees = _formatWithIndianCommas(rupees);
    final sign = isNegative ? '-' : '';
    return '$sign₹$formattedRupees.${remainingPaise.toString().padLeft(2, '0')}';
  }

  /// Formats a price change in paise with a sign prefix.
  ///
  /// Example: 1250 → "+₹12.50"
  /// Example: -1250 → "-₹12.50"
  /// Example: 0 → "₹0.00"
  static String formatChange(int changePaise) {
    if (changePaise == 0) return '₹0.00';
    final prefix = changePaise > 0 ? '+' : '';
    return '$prefix${paiseToCurrency(changePaise)}';
  }

  /// Formats a percentage value with sign and 2 decimal places.
  ///
  /// Example: 0.44 → "+0.44%"
  /// Example: -1.23 → "-1.23%"
  /// Example: 0.0 → "0.00%"
  static String formatChangePercent(double percent) {
    if (percent == 0) return '0.00%';
    final prefix = percent > 0 ? '+' : '';
    return '$prefix${percent.toStringAsFixed(2)}%';
  }

  /// Calculates the weighted average cost after a new buy.
  ///
  /// Formula: (existingQty × existingAvgPaise + newQty × newPricePaise) ~/ totalQty
  ///
  /// All values are in paise. Uses integer division to avoid floating-point.
  ///
  /// Example:
  ///   existing: 10 shares × 250000 paise (₹2,500.00)
  ///   new buy:   5 shares × 270000 paise (₹2,700.00)
  ///   result:   256666 paise (₹2,566.66)
  static int calculateWeightedAvgCost({
    required int existingQty,
    required int existingAvgPaise,
    required int newQty,
    required int newPricePaise,
  }) {
    if (existingQty + newQty == 0) return 0;
    final totalValue =
        (existingQty * existingAvgPaise) + (newQty * newPricePaise);
    return totalValue ~/ (existingQty + newQty);
  }

  /// Formats an integer with Indian-style commas (lakh/crore system).
  ///
  /// Example: 100000 → "1,00,000"
  /// Example: 2845 → "2,845"
  /// Example: 35 → "35"
  static String _formatWithIndianCommas(int number) {
    final str = number.toString();
    if (str.length <= 3) return str;

    // Last 3 digits get a comma before them
    final lastThree = str.substring(str.length - 3);
    final remaining = str.substring(0, str.length - 3);

    // Remaining digits are grouped in pairs (Indian system)
    final buffer = StringBuffer();
    for (var i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }
    return '$buffer,$lastThree';
  }
}
