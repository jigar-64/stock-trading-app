/// Sorting criteria for the Holdings screen.
enum SortCriteria {
  /// Sort by P&L value, descending (default).
  pnlDesc('P&L ↓'),

  /// Sort by stock symbol, ascending (alphabetical).
  symbolAsc('Symbol A-Z'),

  /// Sort by current value, descending.
  currentValueDesc('Value ↓');

  const SortCriteria(this.displayName);

  /// Human-readable label for UI display.
  final String displayName;
}
