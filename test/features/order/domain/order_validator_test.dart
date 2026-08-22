import 'package:flutter_test/flutter_test.dart';

import 'package:stock_trading/features/order/domain/order_validator.dart';

void main() {
  group('OrderValidator - Pure Domain Order Validation', () {
    group('validateQuantity', () {
      test('accepts valid positive integer strings', () {
        expect(OrderValidator.validateQuantity('1'), isNull);
        expect(OrderValidator.validateQuantity('100'), isNull);
      });

      test('rejects empty or null input', () {
        expect(OrderValidator.validateQuantity(null), contains('required'));
        expect(OrderValidator.validateQuantity(''), contains('required'));
        expect(OrderValidator.validateQuantity('   '), contains('required'));
      });

      test('rejects non-numeric input', () {
        expect(OrderValidator.validateQuantity('abc'), contains('numeric'));
      });

      test('rejects fractional/decimal input', () {
        expect(OrderValidator.validateQuantity('1.5'), contains('Fractional'));
        expect(OrderValidator.validateQuantity('10.0'), contains('Fractional'));
      });

      test('rejects zero and negative quantity', () {
        expect(OrderValidator.validateQuantity('0'), contains('at least 1'));
        expect(OrderValidator.validateQuantity('-5'), contains('at least 1'));
      });
    });

    group('validateBuyBalance', () {
      test('accepts buy order value within available wallet balance', () {
        expect(
          OrderValidator.validateBuyBalance(
            orderValuePaise: 500000,
            walletBalancePaise: 1000000,
          ),
          isNull,
        );
      });

      test('rejects buy order exceeding available balance', () {
        final error = OrderValidator.validateBuyBalance(
          orderValuePaise: 1500000,
          walletBalancePaise: 1000000,
        );
        expect(error, contains('Insufficient margin balance'));
        expect(error, contains('Required: ₹15,000.00'));
        expect(error, contains('Available: ₹10,000.00'));
      });

      test('rejects invalid zero or negative order value', () {
        expect(
          OrderValidator.validateBuyBalance(
            orderValuePaise: 0,
            walletBalancePaise: 1000000,
          ),
          contains('Invalid order value'),
        );
      });
    });

    group('validateSellQuantity', () {
      test('accepts valid sell quantity within held quantity', () {
        expect(
          OrderValidator.validateSellQuantity(
            sellQuantity: 5,
            heldQuantity: 10,
          ),
          isNull,
        );
        expect(
          OrderValidator.validateSellQuantity(
            sellQuantity: 10,
            heldQuantity: 10,
          ),
          isNull,
        );
      });

      test('rejects selling more shares than held in portfolio', () {
        final error = OrderValidator.validateSellQuantity(
          sellQuantity: 15,
          heldQuantity: 10,
        );
        expect(error, contains('Exceeds portfolio holdings'));
        expect(error, contains('You hold 10 shares'));
      });

      test('rejects sell order when zero shares are held', () {
        final error = OrderValidator.validateSellQuantity(
          sellQuantity: 1,
          heldQuantity: 0,
        );
        expect(error, contains('You do not own any shares'));
      });
    });
  });
}
