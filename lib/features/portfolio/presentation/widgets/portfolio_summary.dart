import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../market/presentation/providers/market_providers.dart';
import '../providers/holdings_providers.dart';

import '../../../wallet/presentation/providers/wallet_providers.dart';

/// Aggregate Portfolio Summary Header Card (Feature 4).
///
/// Modern Design Highlights:
/// - Sleek dark navy/slate gradient background
/// - Bold P&L typography with soft gain/loss indicator badge
/// - Invested vs Current Value metrics breakdown
class PortfolioSummary extends ConsumerWidget {
  const PortfolioSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdings = ref.watch(holdingsProvider);
    final priceMap = ref.watch(marketPricesProvider);
    final walletBalancePaise = ref.watch(walletBalancePaiseProvider);

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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.summaryGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentIndigo.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title & Wallet Cash badge (Matching Mockup)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PORTFOLIO OVERVIEW',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.accentIndigo,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.priceUp.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.priceUp.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 12, color: AppColors.priceUp),
                    const SizedBox(width: 4),
                    Text(
                      'Wallet ${MoneyUtils.paiseToCurrency(walletBalancePaise)}',
                      style: const TextStyle(
                        color: AppColors.priceUp,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total P&L Main Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Return (P&L)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    MoneyUtils.formatChange(totalPnlPaise),
                    style: TextStyle(
                      color: pnlColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: pnlColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: pnlColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isProfit ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: pnlColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      MoneyUtils.formatChangePercent(totalPnlPercent),
                      style: TextStyle(
                        color: pnlColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),

          // Invested vs Current Value Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Invested',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    MoneyUtils.paiseToCurrency(totalInvestedPaise),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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
                  const SizedBox(height: 4),
                  Text(
                    MoneyUtils.paiseToCurrency(totalCurrentValuePaise),
                    style: const TextStyle(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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
