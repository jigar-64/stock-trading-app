/// Direction of a price movement.
enum PriceDirection {
  up,
  down,
  flat,
}

/// A single price quote for a stock at a point in time.
///
/// All monetary fields are in paise (integer minor units).
/// Change and change percentage are relative to the previous close.
class PriceQuote {
  const PriceQuote({
    required this.symbol,
    required this.ltpPaise,
    required this.previousClosePaise,
    required this.changePaise,
    required this.changePercent,
    required this.direction,
    required this.timestamp,
  });

  /// Stock symbol (e.g., "RELIANCE").
  final String symbol;

  /// Last traded price in paise.
  final int ltpPaise;

  /// Previous close price in paise (set at feed initialization).
  final int previousClosePaise;

  /// Change from previous close in paise: ltpPaise - previousClosePaise.
  final int changePaise;

  /// Change percentage: (changePaise / previousClosePaise) × 100.
  final double changePercent;

  /// Direction of the latest price movement.
  final PriceDirection direction;

  /// Timestamp of this quote.
  final DateTime timestamp;

  /// Creates a copy of this quote with the given fields replaced.
  PriceQuote copyWith({
    int? ltpPaise,
    int? changePaise,
    double? changePercent,
    PriceDirection? direction,
    DateTime? timestamp,
  }) {
    return PriceQuote(
      symbol: symbol,
      ltpPaise: ltpPaise ?? this.ltpPaise,
      previousClosePaise: previousClosePaise,
      changePaise: changePaise ?? this.changePaise,
      changePercent: changePercent ?? this.changePercent,
      direction: direction ?? this.direction,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() =>
      'PriceQuote($symbol, ltp: $ltpPaise, change: $changePaise, dir: $direction)';
}
