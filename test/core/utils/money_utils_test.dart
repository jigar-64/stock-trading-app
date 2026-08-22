import 'package:flutter_test/flutter_test.dart';

import 'package:stock_trading/core/utils/money_utils.dart';

void main() {
  group('MoneyUtils - Currency Formatting & Arithmetic', () {
    test('paiseToCurrency formats positive paise correctly with Indian commas', () {
      expect(MoneyUtils.paiseToCurrency(284535), equals('₹2,845.35'));
      expect(MoneyUtils.paiseToCurrency(10000000), equals('₹1,00,000.00'));
      expect(MoneyUtils.paiseToCurrency(100), equals('₹1.00'));
      expect(MoneyUtils.paiseToCurrency(50), equals('₹0.50'));
      expect(MoneyUtils.paiseToCurrency(0), equals('₹0.00'));
    });

    test('paiseToCurrency formats negative paise correctly', () {
      expect(MoneyUtils.paiseToCurrency(-1250), equals('-₹12.50'));
      expect(MoneyUtils.paiseToCurrency(-284535), equals('-₹2,845.35'));
    });

    test('formatChange adds + sign for positive change and handles zero', () {
      expect(MoneyUtils.formatChange(1250), equals('+₹12.50'));
      expect(MoneyUtils.formatChange(-1250), equals('-₹12.50'));
      expect(MoneyUtils.formatChange(0), equals('₹0.00'));
    });

    test('formatChangePercent adds + sign and formats 2 decimal places', () {
      expect(MoneyUtils.formatChangePercent(0.44), equals('+0.44%'));
      expect(MoneyUtils.formatChangePercent(-1.2345), equals('-1.23%'));
      expect(MoneyUtils.formatChangePercent(0.0), equals('0.00%'));
    });

    test('calculateWeightedAvgCost computes weighted average accurately in integer paise', () {
      // Existing: 10 shares @ ₹2,500.00 (250000 paise)
      // New buy:  5 shares @ ₹2,700.00 (270000 paise)
      // Expected = (10*250000 + 5*270000) ~/ 15 = (2500000 + 1350000) ~/ 15 = 3850000 ~/ 15 = 256666 paise
      final avgCost = MoneyUtils.calculateWeightedAvgCost(
        existingQty: 10,
        existingAvgPaise: 250000,
        newQty: 5,
        newPricePaise: 270000,
      );

      expect(avgCost, equals(256666));
    });

    test('calculateWeightedAvgCost handles initial purchase when existing qty is zero', () {
      final avgCost = MoneyUtils.calculateWeightedAvgCost(
        existingQty: 0,
        existingAvgPaise: 0,
        newQty: 10,
        newPricePaise: 150000,
      );

      expect(avgCost, equals(150000));
    });
  });
}
