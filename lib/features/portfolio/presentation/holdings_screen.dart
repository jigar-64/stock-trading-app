import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/money_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../market/presentation/providers/market_providers.dart';
import '../../wallet/presentation/providers/wallet_providers.dart';
import 'providers/holdings_providers.dart';
import 'widgets/holding_row.dart';
import 'widgets/portfolio_summary.dart';
import 'widgets/sort_selector.dart';

/// Portfolio Holdings view screen (Feature 4).
///
/// Key Capabilities:
/// - Displays list of all currently held stocks with real-time P&L.
/// - Aggregate summary card at top showing total invested, current value, total P&L.
/// - Sortable by P&L (default descending), Symbol (ascending), and Current Value (descending).
/// - Dynamic Re-sorting: Sorted order updates dynamically as live price ticks arrive.
/// - Tapping a row opens the Buy/Sell ticket pre-filled for that stock.
/// - Clear empty state when no holdings exist.
/// - Fully persisted across app restarts via SharedPreferences repository.
class HoldingsScreen extends ConsumerWidget {
  const HoldingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdings = ref.watch(holdingsProvider);
    final priceMap = ref.watch(marketPricesProvider);
    final sortCriteria = ref.watch(sortCriteriaProvider);
    final walletBalancePaise = ref.watch(walletBalancePaiseProvider);

    // Empty state when no holdings exist in portfolio
    if (holdings.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Holdings'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBackground,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Cash: ${MoneyUtils.paiseToCurrency(walletBalancePaise)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: EmptyStateWidget(
          icon: Icons.account_balance_wallet_outlined,
          title: 'No Holdings Yet',
          subtitle:
              'Place a market BUY order from the Live Market or Watchlists to start building your portfolio.',
          actionLabel: 'Explore Live Market',
          onActionPressed: () => context.go('/market'),
        ),
      );
    }

    // Sort holdings dynamically based on current sort criteria and live prices
    final sortedHoldings = List.of(holdings)..sort((a, b) {
      final quoteA = priceMap[a.symbol];
      final quoteB = priceMap[b.symbol];

      final ltpA = quoteA?.ltpPaise ?? a.avgCostPaise;
      final ltpB = quoteB?.ltpPaise ?? b.avgCostPaise;

      final valA = a.quantity * ltpA;
      final valB = b.quantity * ltpB;

      final pnlA = valA - a.investedPaise;
      final pnlB = valB - b.investedPaise;

      switch (sortCriteria) {
        case SortCriteria.pnlDesc:
          return pnlB.compareTo(pnlA); // P&L descending (default)
        case SortCriteria.symbolAsc:
          return a.symbol.compareTo(b.symbol); // Symbol A-Z
        case SortCriteria.currentValueDesc:
          return valB.compareTo(valA); // Current Value descending
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Holdings'),
            Text(
              '${holdings.length} Position${holdings.length > 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          // Wallet cash balance badge
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Cash: ${MoneyUtils.paiseToCurrency(walletBalancePaise)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Aggregate Portfolio Summary Header Card
          const PortfolioSummary(),

          // Sort Criteria Selector Bar
          const SortSelector(),

          const SizedBox(height: 4),

          // List of sorted holding rows
          Expanded(
            child: ListView.builder(
              itemCount: sortedHoldings.length,
              padding: const EdgeInsets.only(bottom: 16),
              itemBuilder: (context, index) {
                final holding = sortedHoldings[index];
                return HoldingRow(
                  key: ValueKey('holding_${holding.symbol}'),
                  holding: holding,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
