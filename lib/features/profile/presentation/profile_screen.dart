import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../../market/presentation/providers/market_providers.dart';
import '../../order/domain/order_model.dart';
import '../../order/presentation/providers/order_providers.dart';
import '../../portfolio/presentation/providers/holdings_providers.dart';
import '../../wallet/presentation/providers/wallet_providers.dart';

/// User Profile & Account Settings Screen.
///
/// Features:
/// 1. Trader Identity Header: KYC status badge, Client ID, Account Type.
/// 2. Live Account Financial Summary: Wallet balance, invested value, current portfolio value, total return.
/// 3. Trade Execution History: List of all executed buy/sell orders with full timestamp and pricing details.
/// 4. Stress Mode Toggle & Demo Account Reset capability.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// Opens confirmation dialog to reset demo account.
  Future<void> _showResetAccountDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Reset Demo Account?'),
        content: const Text(
          'This will reset your wallet balance back to ₹1,00,000.00, clear all portfolio holdings, and wipe order history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sellRed,
            ),
            child: const Text('Reset Account'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(walletProvider.notifier).resetWallet();
      await ref.read(holdingsProvider.notifier).resetHoldings();
      await ref.read(ordersProvider.notifier).resetOrders();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo account successfully reset to ₹1,00,000.00'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletBalancePaise = ref.watch(walletBalancePaiseProvider);
    final holdings = ref.watch(holdingsProvider);
    final priceMap = ref.watch(marketPricesProvider);
    final orders = ref.watch(ordersProvider);
    final isStressMode = ref.watch(stressModeProvider);

    // Compute portfolio financial stats
    int totalInvestedPaise = 0;
    int totalCurrentValuePaise = 0;

    for (final holding in holdings) {
      totalInvestedPaise += holding.investedPaise;
      final quote = priceMap[holding.symbol];
      final currentLtp = quote?.ltpPaise ?? holding.avgCostPaise;
      totalCurrentValuePaise += holding.quantity * currentLtp;
    }

    final totalPnlPaise = totalCurrentValuePaise - totalInvestedPaise;
    final totalPnlPercent = totalInvestedPaise > 0
        ? (totalPnlPaise / totalInvestedPaise) * 100.0
        : 0.0;

    final isProfit = totalPnlPaise >= 0;
    final pnlColor = isProfit ? AppColors.priceUp : AppColors.priceDown;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trader Profile'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.priceUp.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.priceUp.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 14, color: AppColors.priceUp),
                SizedBox(width: 4),
                Text(
                  'KYC VERIFIED',
                  style: TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trader Identity Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar Profile Badge
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentIndigo.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'JP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jigar Prajapati',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Client ID: TRD-884920',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceBackground,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            'Margin Trading Account • NSE India',
                            style: TextStyle(
                              color: AppColors.accentIndigo,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Account Financial Summary Grid
            Text(
              'ACCOUNT & FUNDS SUMMARY',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Margin Cash Balance',
                    value: MoneyUtils.paiseToCurrency(walletBalancePaise),
                    valueColor: AppColors.accentBlue,
                    icon: Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Total Portfolio Return',
                    value: MoneyUtils.formatChange(totalPnlPaise),
                    valueColor: pnlColor,
                    subtitle: MoneyUtils.formatChangePercent(totalPnlPercent),
                    icon: isProfit ? Icons.trending_up : Icons.trending_down,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Invested',
                    value: MoneyUtils.paiseToCurrency(totalInvestedPaise),
                    valueColor: AppColors.textPrimary,
                    icon: Icons.savings,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Current Value',
                    value: MoneyUtils.paiseToCurrency(totalCurrentValuePaise),
                    valueColor: AppColors.accentPurple,
                    icon: Icons.pie_chart,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Feed Settings & Demo Controls
            Text(
              'FEED SETTINGS & DEMO CONTROLS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Market Feed Speed',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Normal (~500ms) vs Stress Mode (50+ ticks/s)',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: isStressMode,
                        activeColor: Colors.amber,
                        onChanged: (val) {
                          ref.read(stressModeProvider.notifier).setStressMode(val);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showResetAccountDialog(context, ref),
                      icon: const Icon(Icons.refresh, color: AppColors.sellRed),
                      label: const Text(
                        'Reset Demo Account State',
                        style: TextStyle(
                          color: AppColors.sellRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.sellRed),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Trade Execution History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TRADE EXECUTION HISTORY',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBackground,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${orders.length} Order${orders.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (orders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      size: 40,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No Executed Orders Yet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Executed Buy and Sell market orders will appear here.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _OrderHistoryTile(order: order);
                },
              ),
            const SizedBox(height: 32),

            // App Version Footer
            const Center(
              child: Text(
                '021 Trading App v1.0.0 • Production Channel\nFlutter • Riverpod • SharedPreferences',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.valueColor,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final String value;
  final Color valueColor;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: valueColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                color: valueColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderHistoryTile extends StatelessWidget {
  const _OrderHistoryTile({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSide.buy;
    final sideColor = isBuy ? AppColors.buyGreen : AppColors.sellRed;
    final formattedTime =
        '${order.timestamp.hour.toString().padLeft(2, '0')}:${order.timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: sideColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: sideColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              order.side.displayName.toUpperCase(),
              style: TextStyle(
                color: sideColor,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.quantity} shares of ${order.symbol}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@ ${MoneyUtils.paiseToCurrency(order.executionPricePaise)} per share • $formattedTime',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            MoneyUtils.paiseToCurrency(order.orderValuePaise),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
