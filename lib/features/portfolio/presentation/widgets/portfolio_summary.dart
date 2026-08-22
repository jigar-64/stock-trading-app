import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../market/presentation/providers/market_providers.dart';
import '../providers/holdings_providers.dart';

/// Aggregate Portfolio Summary Header Card (Feature 4).
///
/// Computes and renders aggregate portfolio statistics in real time:
/// - Total Invested: Sum of `(quantity × avgCostPaise)` for all holdings
/// - Total Current Value: Sum of `(quantity × liveLTPPaise)` for all holdings
/// - Total P&L (₹): `totalCurrentValue - totalInvested`
/// - Total P&L (%): `(totalPnL / totalInvested) × 100`
///
/// Realtime Integrity:
/// Reads live market prices continuously so aggregate numbers ALWAYS match
/// the sum of individual holding rows at any given moment.
class PortfolioSummary extends ConsumerWidget {
  const PortfolioSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdings = ref.watch(holdingsProvider);
    final priceMap = ref.watch(marketPricesProvider);

    if (holdings.isEmpty) {
      return const SizedBox.shrink();
    }

    int totalInvestedPaise = 0;
    int totalCurrentValuePaise = 0;

    for (final holding in holdings) {
      totalInvestedPaise += holding.investedPaise;
      final quote = priceMap[holding.symbol];
      final currentLtpPaise = quote?.ltpPaise ?? holding.avgCostPaise;
      totalCurrentValuePaise += holding.quantity * currentLtpPaise;
    }

    final totalPnlPaise = totalCurrentValuePaise - totalInvestedPaise;
    final totalPnlPercent = totalInvestedPaise > 0
        ? (totalPnlPaise / totalInvestedPaise) * 100.0
        : 0.0;

    final isProfit = totalPnlPaise >= 0;
    final pnlColor = isProfit ? AppColors.priceUp : AppColors.priceDown;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title
          Text(
            'PORTFOLIO SUMMARY',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 12),

          // Total P&L Main Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total P&L',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        MoneyUtils.formatChange(totalPnlPaise),
                        style: TextStyle(
                          color: pnlColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: pnlColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  MoneyUtils.formatChangePercent(totalPnlPercent),
                  style: TextStyle(
                    color: pnlColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Invested vs Current Value Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invested',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    MoneyUtils.paiseToCurrency(totalInvestedPaise),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Current Value',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    MoneyUtils.paiseToCurrency(totalCurrentValuePaise),
                    style: const TextStyle(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
