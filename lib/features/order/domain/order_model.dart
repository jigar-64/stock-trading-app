import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// The side of an order: buy or sell.
enum OrderSide {
  buy,
  sell;

  String get displayName => name[0].toUpperCase() + name.substring(1);
}

/// A recorded order (buy or sell) that has been executed.
///
/// All monetary values are in paise (integer minor units).
/// The execution price is the LTP at the moment of submission.
class Order {
  Order({
    String? id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.executionPricePaise,
    required this.orderValuePaise,
    DateTime? timestamp,
  })  : id = id ?? _uuid.v4(),
        timestamp = timestamp ?? DateTime.now();

  /// Unique identifier for this order.
  final String id;

  /// Stock symbol (e.g., "RELIANCE").
  final String symbol;

  /// Whether this was a buy or sell order.
  final OrderSide side;

  /// Number of shares traded.
  final int quantity;

  /// Price per share at execution in paise.
  final int executionPricePaise;

  /// Total order value in paise: quantity × executionPricePaise.
  final int orderValuePaise;

  /// When the order was executed.
  final DateTime timestamp;

  /// Serializes this order to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side.name,
      'quantity': quantity,
      'executionPricePaise': executionPricePaise,
      'orderValuePaise': orderValuePaise,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Deserializes an order from a JSON-compatible map.
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      side: OrderSide.values.byName(json['side'] as String),
      quantity: json['quantity'] as int,
      executionPricePaise: json['executionPricePaise'] as int,
      orderValuePaise: json['orderValuePaise'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() =>
      'Order($id, ${side.displayName} $quantity × $symbol @ $executionPricePaise paise)';
}
