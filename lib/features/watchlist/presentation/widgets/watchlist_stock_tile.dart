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
/// Critical Realtime Correctness (Symbol-Based Price Identity):
/// This tile is passed a `Key(symbol)` and a `symbol` prop.
/// It subscribes ONLY to `ref.watch(singleStockPriceProvider(symbol))`.
///
/// When stocks are reordered in the watchlist (e.g. moving INFY above RELIANCE):
/// 1. ReorderableListView updates the position.
/// 2. The widget receives the new symbol for its position.
/// 3. The provider selector dynamically binds to the new symbol's live quote.
/// Result: Stale price ticks NEVER cross over to the wrong stock row!
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

    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
        // Tapping opens the Buy/Sell ticket pre-filled with this stock
        onTap: () => context.push('/order/$symbol'),
        borderRadius: BorderRadius.circular(12),
        child: FlashContainer(
          direction: quote.direction,
          timestamp: quote.timestamp,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Reorder Drag Handle (for ReorderableListView)
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.drag_handle,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),

              // Stock Symbol & Company Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      quote.symbol,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      companyName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
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
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 4),
                  PriceChangeText(
                    changePaise: quote.changePaise,
                    changePercent: quote.changePercent,
                  ),
                ],
              ),

              // Remove from Watchlist Action Button
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
  );
}
}
