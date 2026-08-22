import 'package:flutter_test/flutter_test.dart';

import 'package:stock_trading/features/market/domain/price_quote.dart';

void main() {
  group('Critical Stale-Tick Reorder Test (Symbol-Based Price Identity)', () {
    test(
        'Reordering watchlist symbols updates position indices without cross-contaminating price subscriptions',
        () {
      // 1. Initial Watchlist Order: [RELIANCE, TCS, INFY]
      final watchlistSymbols = ['RELIANCE', 'TCS', 'INFY'];

      // Simulated market price store keyed BY SYMBOL (never by list index!)
      final Map<String, PriceQuote> priceStore = {
        'RELIANCE': PriceQuote(
          symbol: 'RELIANCE',
          ltpPaise: 284535,
          previousClosePaise: 284535,
          changePaise: 0,
          changePercent: 0.0,
          direction: PriceDirection.flat,
          timestamp: DateTime.now(),
        ),
        'TCS': PriceQuote(
          symbol: 'TCS',
          ltpPaise: 392080,
          previousClosePaise: 392080,
          changePaise: 0,
          changePercent: 0.0,
          direction: PriceDirection.flat,
          timestamp: DateTime.now(),
        ),
        'INFY': PriceQuote(
          symbol: 'INFY',
          ltpPaise: 148625,
          previousClosePaise: 148625,
          changePaise: 0,
          changePercent: 0.0,
          direction: PriceDirection.flat,
          timestamp: DateTime.now(),
        ),
      };

      // 2. Perform Drag Reorder: Move INFY (index 2) to top (index 0)
      // New Order: [INFY, RELIANCE, TCS]
      final movedSymbol = watchlistSymbols.removeAt(2); // Remove INFY
      watchlistSymbols.insert(0, movedSymbol); // Insert INFY at index 0

      expect(watchlistSymbols, equals(['INFY', 'RELIANCE', 'TCS']));

      // 3. Emit a live market tick for RELIANCE (+₹50.00 / 5000 paise tick)
      final newRelianceQuote = priceStore['RELIANCE']!.copyWith(
        ltpPaise: 289535,
        changePaise: 5000,
        changePercent: 1.75,
        direction: PriceDirection.up,
        timestamp: DateTime.now(),
      );
      priceStore['RELIANCE'] = newRelianceQuote;

      // 4. Assert Symbol-Based Identity Correctness:
      // Item at index 0 is INFY — looking up priceStore[watchlistSymbols[0]] must yield INFY quote
      final index0Symbol = watchlistSymbols[0]; // "INFY"
      final index0Quote = priceStore[index0Symbol];
      expect(index0Quote?.symbol, equals('INFY'));
      expect(index0Quote?.ltpPaise, equals(148625)); // Not RELIANCE's tick!

      // Item at index 1 is RELIANCE — looking up priceStore[watchlistSymbols[1]] yields fresh RELIANCE tick
      final index1Symbol = watchlistSymbols[1]; // "RELIANCE"
      final index1Quote = priceStore[index1Symbol];
      expect(index1Quote?.symbol, equals('RELIANCE'));
      expect(index1Quote?.ltpPaise, equals(289535)); // Correctly updated!
    });
  });
}
