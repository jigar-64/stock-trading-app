import 'package:flutter_test/flutter_test.dart';

import 'package:stock_trading/features/portfolio/domain/holding_model.dart';

void main() {
  group('Holding & Portfolio P&L Calculation Logic', () {
    test('Holding calculates investedPaise accurately', () {
      const holding = Holding(
        symbol: 'RELIANCE',
        quantity: 10,
        avgCostPaise: 250000, // ₹2,500.00
      );

      expect(holding.investedPaise, equals(2500000)); // ₹25,000.00
    });

    test('P&L and Current Value are derived correctly from live LTP', () {
      const holding = Holding(
        symbol: 'RELIANCE',
        quantity: 10,
        avgCostPaise: 250000, // ₹2,500.00
      );

      const liveLtpPaise = 270000; // ₹2,700.00 (+₹200 / +8%)

      final currentValuePaise = holding.quantity * liveLtpPaise;
      final pnlPaise = currentValuePaise - holding.investedPaise;
      final pnlPercent = (pnlPaise / holding.investedPaise) * 100.0;

      expect(currentValuePaise, equals(2700000)); // ₹27,000.00
      expect(pnlPaise, equals(200000)); // +₹2,000.00 profit
      expect(pnlPercent, equals(8.0)); // +8.00%
    });

    test('Holdings sorting comparators work correctly', () {
      const h1 = Holding(symbol: 'INFY', quantity: 10, avgCostPaise: 100000);
      const h2 = Holding(symbol: 'TCS', quantity: 10, avgCostPaise: 200000);
      const h3 = Holding(symbol: 'RELIANCE', quantity: 10, avgCostPaise: 150000);

      final holdings = [h1, h2, h3];

      // Sort by Symbol Ascending (A-Z)
      final sortedBySymbol = List.of(holdings)
        ..sort((a, b) => a.symbol.compareTo(b.symbol));
      expect(sortedBySymbol.map((h) => h.symbol), equals(['INFY', 'RELIANCE', 'TCS']));

      // Sort by Invested Value Descending
      final sortedByInvested = List.of(holdings)
        ..sort((a, b) => b.investedPaise.compareTo(a.investedPaise));
      expect(sortedByInvested.map((h) => h.symbol), equals(['TCS', 'RELIANCE', 'INFY']));
    });
  });
}
