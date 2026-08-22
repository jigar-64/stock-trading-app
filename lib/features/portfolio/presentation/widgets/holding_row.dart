import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/stock_constants.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/flash_container.dart';
import '../../../../core/widgets/price_change_text.dart';
import '../../../market/domain/price_quote.dart';
import '../../../market/presentation/providers/market_providers.dart';
import '../../domain/holding_model.dart';

/// A single portfolio holding row in the Holdings view (Feature 4).
///
/// Subscribes EXCLUSIVELY to its specific stock symbol via [singleStockPriceProvider].
/// Live P&L and current values are DERIVED on the fly as ticks arrive:
/// - `currentValuePaise = holding.quantity × liveLTP`
/// - `pnlPaise = currentValuePaise - holding.investedPaise`
/// - `pnlPercent = (pnlPaise / holding.investedPaise) × 100`
class HoldingRow extends ConsumerWidget {
  const HoldingRow({
    super.key,
    required this.holding,
  });

  /// The holding business data (symbol, quantity, avgCostPaise).
  final Holding holding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fine-grained Riverpod selector: Subscribes ONLY to this stock symbol's price quote
    final quote = ref.watch(singleStockPriceProvider(holding.symbol));
    final companyName = StockConstants.companyNames[holding.symbol] ?? holding.symbol;

    final currentLtpPaise = quote?.ltpPaise ?? holding.avgCostPaise;
    final currentValuePaise = holding.quantity * currentLtpPaise;
    final pnlPaise = currentValuePaise - holding.investedPaise;
    final pnlPercent = holding.investedPaise > 0
        ? (pnlPaise / holding.investedPaise) * 100.0
        : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        // Tapping opens the Buy/Sell ticket pre-filled for this stock
        onTap: () => context.push('/order/${holding.symbol}'),
        borderRadius: BorderRadius.circular(12),
        child: FlashContainer(
          direction: quote?.direction ?? PriceDirection.flat,
          timestamp: quote?.timestamp ?? DateTime.now(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              // Top Line: Symbol + Qty and Live Current Value
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            holding.symbol,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBackground,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              '${holding.quantity} qty',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        companyName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        MoneyUtils.paiseToCurrency(currentValuePaise),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'LTP: ${MoneyUtils.paiseToCurrency(currentLtpPaise)}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),

              // Bottom Line: Avg Cost vs Live P&L
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avg Cost: ${MoneyUtils.paiseToCurrency(holding.avgCostPaise)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  PriceChangeText(
                    changePaise: pnlPaise,
                    changePercent: pnlPercent,
                    fontSize: 12,
                    showBadge: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
