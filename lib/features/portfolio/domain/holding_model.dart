/// A stock holding representing shares owned by the user.
///
/// Holdings store only business ownership data (quantity and average cost).
/// P&L is DERIVED at display time using the live LTP from the market feed —
/// it is never stored in the holding itself.
///
/// All monetary values are in paise (integer minor units).
class Holding {
  const Holding({
    required this.symbol,
    required this.quantity,
    required this.avgCostPaise,
  });

  /// Stock symbol (e.g., "RELIANCE").
  final String symbol;

  /// Number of shares held. Always a positive integer.
  final int quantity;

  /// Weighted average cost per share in paise.
  final int avgCostPaise;

  /// Total invested value in paise: quantity × avgCostPaise.
  int get investedPaise => quantity * avgCostPaise;

  /// Creates a copy with the given fields replaced.
  Holding copyWith({
    int? quantity,
    int? avgCostPaise,
  }) {
    return Holding(
      symbol: symbol,
      quantity: quantity ?? this.quantity,
      avgCostPaise: avgCostPaise ?? this.avgCostPaise,
    );
  }

  /// Serializes this holding to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'quantity': quantity,
      'avgCostPaise': avgCostPaise,
    };
  }

  /// Deserializes a holding from a JSON-compatible map.
  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      symbol: json['symbol'] as String,
      quantity: json['quantity'] as int,
      avgCostPaise: json['avgCostPaise'] as int,
    );
  }

  @override
  String toString() =>
      'Holding($symbol, qty: $quantity, avgCost: $avgCostPaise paise)';
}
