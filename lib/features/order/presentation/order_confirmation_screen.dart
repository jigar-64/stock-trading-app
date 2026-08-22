import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../domain/order_model.dart';

/// Screen displayed immediately after a successful trade execution.
///
/// Displays a receipt showing:
/// - Order Side (BUY / SELL) & Symbol
/// - Executed Quantity
/// - Execution LTP (price per share at execution moment)
/// - Total Order Value
/// - Updated Wallet Balance
/// - Execution Timestamp
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({
    super.key,
    required this.order,
    required this.remainingBalancePaise,
  });

  /// The executed order details.
  final Order order;

  /// Remaining wallet balance after trade execution in paise.
  final int remainingBalancePaise;

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSide.buy;
    final sideColor = isBuy ? AppColors.buyGreen : AppColors.sellRed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Success Animated Checkmark Badge
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: sideColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: sideColor, width: 2),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: sideColor,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Order Executed Successfully!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Market ${order.side.displayName} Order for ${order.symbol}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Order Summary Card Receipt
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _ReceiptRow(
                        label: 'Side',
                        valueWidget: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: sideColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            order.side.displayName.toUpperCase(),
                            style: TextStyle(
                              color: sideColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      _ReceiptRow(
                        label: 'Stock Symbol',
                        value: order.symbol,
                        isBold: true,
                      ),
                      const Divider(height: 24),
                      _ReceiptRow(
                        label: 'Quantity',
                        value: '${order.quantity} shares',
                      ),
                      const Divider(height: 24),
                      _ReceiptRow(
                        label: 'Execution LTP',
                        value: MoneyUtils.paiseToCurrency(order.executionPricePaise),
                      ),
                      const Divider(height: 24),
                      _ReceiptRow(
                        label: 'Total Order Value',
                        value: MoneyUtils.paiseToCurrency(order.orderValuePaise),
                        isBold: true,
                        valueColor: AppColors.textPrimary,
                      ),
                      const Divider(height: 24),
                      _ReceiptRow(
                        label: 'Updated Wallet Balance',
                        value: MoneyUtils.paiseToCurrency(remainingBalancePaise),
                        valueColor: AppColors.accentBlue,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Done Action Button (Pops back to portfolio / market)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/holdings');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentIndigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        if (valueWidget != null)
          valueWidget!
        else
          Text(
            value ?? '',
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
