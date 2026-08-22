import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// A named collection of stock symbols that the user is watching.
///
/// The [symbols] list is ordered — the order reflects the user's
/// preferred arrangement (drag-to-reorder). Each symbol is unique
/// within a watchlist.
class Watchlist {
  Watchlist({
    String? id,
    required this.name,
    List<String>? symbols,
  })  : id = id ?? _uuid.v4(),
        symbols = symbols ?? [];

  /// Unique identifier for this watchlist.
  final String id;

  /// User-defined name (e.g., "My Stocks", "Banking").
  final String name;

  /// Ordered list of stock symbols in this watchlist.
  final List<String> symbols;

  /// Creates a copy with the given fields replaced.
  Watchlist copyWith({
    String? name,
    List<String>? symbols,
  }) {
    return Watchlist(
      id: id,
      name: name ?? this.name,
      symbols: symbols ?? List.from(this.symbols),
    );
  }

  /// Serializes this watchlist to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbols': symbols,
    };
  }

  /// Deserializes a watchlist from a JSON-compatible map.
  factory Watchlist.fromJson(Map<String, dynamic> json) {
    return Watchlist(
      id: json['id'] as String,
      name: json['name'] as String,
      symbols: List<String>.from(json['symbols'] as List),
    );
  }

  @override
  String toString() => 'Watchlist($id, "$name", ${symbols.length} stocks)';
}
