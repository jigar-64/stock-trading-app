import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/stock_constants.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/flash_container.dart';
import '../../../../core/widgets/price_change_text.dart';
import '../../../market/presentation/providers/market_providers.dart';

/// A single stock row in a watchlist tab.
///
/// Modern Design Highlights:
/// - Reorder drag handle & stock avatar badge
/// - Symbol-based price identity for zero stale tick cross-contamination
/// - RepaintBoundary for isolated GPU layer repaints
class WatchlistStockTile extends ConsumerWidget {
  const WatchlistStockTile({
    super.key,
    required this.symbol,
    required this.index,
    required this.onRemove,
  });

  /// Stock symbol (e.g., "RELIANCE").
  final String symbol;

  /// Index of the stock in the reorderable list.
  final int index;

  /// Callback to remove this stock from the current watchlist.
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fine-grained Riverpod selector: Subscribes exclusively to this stock symbol's price quote
    final quote = ref.watch(singleStockPriceProvider(symbol));
    final companyName = StockConstants.companyNames[symbol] ?? symbol;

    if (quote == null) {
      return const SizedBox.shrink();
    }

    final initial = symbol.isNotEmpty ? symbol[0] : 'S';

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
            onTap: () => context.push('/order/$symbol'),
            borderRadius: BorderRadius.circular(16),
            child: FlashContainer(
              direction: quote.direction,
              timestamp: quote.timestamp,
              borderRadius: 16.0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  // Reorder Drag Handle
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8, left: 4),
                      child: Icon(
                        Icons.drag_indicator,
                        color: AppColors.textMuted,
                        size: 22,
                      ),
                    ),
                  ),

                  // Stock Avatar Badge
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.accentIndigo.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: AppColors.accentIndigo,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Stock Symbol & Company Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          quote.symbol,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: 0.3,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          companyName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Live LTP & Price Change Indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        MoneyUtils.paiseToCurrency(quote.ltpPaise),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                      ),
                      const SizedBox(height: 3),
                      PriceChangeText(
                        changePaise: quote.changePaise,
                        changePercent: quote.changePercent,
                        fontSize: 11,
                        showBadge: true,
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),

                  // Remove Action Button
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    tooltip: 'Remove from Watchlist',
                    onPressed: onRemove,
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
