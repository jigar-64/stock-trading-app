import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../core/utils/money_utils.dart';
import '../../../core/widgets/price_change_text.dart';
import '../../market/presentation/providers/market_providers.dart';
import '../../portfolio/presentation/providers/holdings_providers.dart';
import '../../wallet/presentation/providers/wallet_providers.dart';
import '../domain/order_model.dart';
import '../domain/order_validator.dart';
import 'order_confirmation_screen.dart';
import 'providers/order_providers.dart';

/// Simulated Market Buy/Sell Order Ticket Screen (Feature 3).
///
/// Key Requirements & Features:
/// 1. Pre-filled stock symbol passed via GoRouter path parameter (`/order/:symbol`).
/// 2. Live LTP display updating in real time as market ticks arrive.
/// 3. Live projected order value: `quantity × current LTP` updating in real time.
/// 4. Side selection toggle (Buy vs Sell).
/// 5. Margin/balance check for Buy orders; portfolio held quantity check for Sell orders.
/// 6. Realtime inline validation feedback preventing invalid orders.
/// 7. Execution-time LTP snapshot: Reads current LTP directly from market store at submission.
/// 8. Automatic wallet balance deduction/credit, holding creation/update/removal, and order recording.
class OrderTicketScreen extends ConsumerStatefulWidget {
  const OrderTicketScreen({
    super.key,
    required this.symbol,
  });

  /// Pre-filled stock symbol string.
  final String symbol;

  @override
  ConsumerState<OrderTicketScreen> createState() => _OrderTicketScreenState();
}

class _OrderTicketScreenState extends ConsumerState<OrderTicketScreen> {
  final TextEditingController _qtyController = TextEditingController(text: '1');
  OrderSide _selectedSide = OrderSide.buy;
  String? _inlineError;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  /// Calculates the projected order value in paise based on current quantity input and LTP.
  int _calculateOrderValuePaise(int ltpPaise) {
    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    if (qty <= 0) return 0;
    return qty * ltpPaise;
  }

  /// Validates the order form fields and updates [_inlineError].
  bool _validateForm({
    required int ltpPaise,
    required int walletBalancePaise,
    required int heldQuantity,
  }) {
    // 1. Quantity format validation
    final qtyError = OrderValidator.validateQuantity(_qtyController.text);
    if (qtyError != null) {
      setState(() => _inlineError = qtyError);
      return false;
    }

    final qty = int.parse(_qtyController.text.trim());
    final orderValuePaise = qty * ltpPaise;

    // 2. Business logic validation based on trade side
    if (_selectedSide == OrderSide.buy) {
      final balanceError = OrderValidator.validateBuyBalance(
        orderValuePaise: orderValuePaise,
        walletBalancePaise: walletBalancePaise,
      );
      if (balanceError != null) {
        setState(() => _inlineError = balanceError);
        return false;
      }
    } else {
      final sellError = OrderValidator.validateSellQuantity(
        sellQuantity: qty,
        heldQuantity: heldQuantity,
      );
      if (sellError != null) {
        setState(() => _inlineError = sellError);
        return false;
      }
    }

    // Form is valid!
    setState(() => _inlineError = null);
    return true;
  }

  /// Submits and executes the market order.
  Future<void> _submitOrder({
    required int executionPricePaise,
    required int walletBalancePaise,
    required int heldQuantity,
  }) async {
    // 1. Validate form fields first
    final isValid = _validateForm(
      ltpPaise: executionPricePaise,
      walletBalancePaise: walletBalancePaise,
      heldQuantity: heldQuantity,
    );

    if (!isValid) return;

    final qty = int.parse(_qtyController.text.trim());
    final orderValuePaise = qty * executionPricePaise;

    final isBuy = _selectedSide == OrderSide.buy;

    // 2. Execute Wallet balance update
    if (isBuy) {
      final success = await ref
          .read(walletProvider.notifier)
          .deductBalance(orderValuePaise);
      if (!success) {
        setState(() => _inlineError = 'Failed to deduct wallet balance.');
        return;
      }
    } else {
      await ref
          .read(walletProvider.notifier)
          .creditBalance(orderValuePaise);
    }

    // 3. Execute Holdings update
    if (isBuy) {
      await ref.read(holdingsProvider.notifier).addOrUpdateHolding(
            symbol: widget.symbol,
            quantity: qty,
            executionPricePaise: executionPricePaise,
          );
    } else {
      await ref.read(holdingsProvider.notifier).reduceHolding(
            symbol: widget.symbol,
            quantity: qty,
          );
    }

    // 4. Record Order details
    final executedOrder = Order(
      symbol: widget.symbol,
      side: _selectedSide,
      quantity: qty,
      executionPricePaise: executionPricePaise,
      orderValuePaise: orderValuePaise,
    );
    await ref.read(ordersProvider.notifier).recordOrder(executedOrder);

    // 5. Get updated wallet balance for receipt display
    final remainingBalance = ref.read(walletBalancePaiseProvider);

    // 6. Navigate to confirmation screen
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(
          order: executedOrder,
          remainingBalancePaise: remainingBalance,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fine-grained live price selector for this stock
    final quote = ref.watch(singleStockPriceProvider(widget.symbol));
    final companyName = StockConstants.companyNames[widget.symbol] ?? widget.symbol;

    // Wallet balance & portfolio holding data
    final walletBalancePaise = ref.watch(walletBalancePaiseProvider);
    final holding = ref.watch(holdingForSymbolProvider(widget.symbol));
    final heldQuantity = holding?.quantity ?? 0;

    final ltpPaise = quote?.ltpPaise ?? 0;
    final orderValuePaise = _calculateOrderValuePaise(ltpPaise);
    final isBuy = _selectedSide == OrderSide.buy;
    final actionColor = isBuy ? AppColors.buyGreen : AppColors.sellRed;

    return Scaffold(
      appBar: AppBar(
        title: Text('${isBuy ? 'Buy' : 'Sell'} ${widget.symbol}'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock Header Tile
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.symbol,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            companyName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (quote != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              MoneyUtils.paiseToCurrency(quote.ltpPaise),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            PriceChangeText(
                              changePaise: quote.changePaise,
                              changePercent: quote.changePercent,
                              fontSize: 12,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Side Toggle (BUY vs SELL)
              SegmentedButton<OrderSide>(
                segments: const [
                  ButtonSegment<OrderSide>(
                    value: OrderSide.buy,
                    label: Text('BUY'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment<OrderSide>(
                    value: OrderSide.sell,
                    label: Text('SELL'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_selectedSide},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return actionColor;
                    }
                    return AppColors.surfaceBackground;
                  }),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedSide = newSelection.first;
                    _inlineError = null; // Clear error on mode switch
                  });
                },
              ),
              const SizedBox(height: 24),

              // Quantity Input Field
              Text(
                'Quantity (Shares)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  suffixText: 'shares',
                  errorText: _inlineError,
                ),
                onChanged: (_) {
                  setState(() {
                    // Trigger live order value recalculation & clear old error
                    _inlineError = null;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Projected Order Value Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Projected Order Value',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      MoneyUtils.paiseToCurrency(orderValuePaise),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Margin Balance / Held Shares Context Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBuy ? 'Available Margin Balance' : 'Shares Currently Held',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      isBuy
                          ? MoneyUtils.paiseToCurrency(walletBalancePaise)
                          : '$heldQuantity shares',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isBuy ? AppColors.textPrimary : AppColors.accentPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Order Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: ltpPaise == 0
                      ? null
                      : () => _submitOrder(
                            executionPricePaise: ltpPaise,
                            walletBalancePaise: walletBalancePaise,
                            heldQuantity: heldQuantity,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Place ${isBuy ? 'BUY' : 'SELL'} Order',
                    style: const TextStyle(
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
    ),
  );
}
}
