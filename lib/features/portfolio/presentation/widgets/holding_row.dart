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
/// Modern Design Highlights:
/// - Avatar Ticker Icon
/// - Glassmorphic / Gradient position details
/// - Dynamic live P&L badge
/// - RepaintBoundary for isolated GPU layer repaints
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

    final initial = holding.symbol.isNotEmpty ? holding.symbol[0] : 'S';

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => context.push('/order/${holding.symbol}'),
            borderRadius: BorderRadius.circular(16),
            child: FlashContainer(
              direction: quote?.direction ?? PriceDirection.flat,
              timestamp: quote?.timestamp ?? DateTime.now(),
              borderRadius: 16.0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  // Top Line: Ticker Avatar, Symbol + Qty, Live Current Value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.accentPurple.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: AppColors.accentPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    holding.symbol,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          letterSpacing: 0.3,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentIndigo.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${holding.quantity} QTY',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.accentIndigo,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                companyName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            MoneyUtils.paiseToCurrency(currentValuePaise),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'LTP: ${MoneyUtils.paiseToCurrency(currentLtpPaise)}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Bottom Line: Avg Cost vs Live P&L Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Avg Cost: ${MoneyUtils.paiseToCurrency(holding.avgCostPaise)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }
}
