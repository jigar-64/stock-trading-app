import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/stock_constants.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/flash_container.dart';
import '../../../../core/widgets/price_change_text.dart';
import '../providers/market_providers.dart';

/// A single stock tile rendered in the Live Prices Mimic view (Feature 2).
///
/// Performance Optimization:
/// This tile is a [ConsumerWidget] that listens EXCLUSIVELY to its specific stock symbol
/// via `ref.watch(singleStockPriceProvider(symbol))`.
///
/// Why this matters:
/// When a tick arrives for "TCS", Riverpod notifies only the TCS MarketPriceTile.
/// Unrelated rows (RELIANCE, INFY, etc.) do NOT rebuild, preventing dropped frames
/// and visible UI jank even when tick rates exceed 50+ ticks/second.
class MarketPriceTile extends ConsumerWidget {
  const MarketPriceTile({
    super.key,
    required this.symbol,
  });

  /// The stock symbol represented by this tile (e.g., "RELIANCE").
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fine-grained Riverpod selector: Subscribes ONLY to price updates for this specific symbol.
    final quote = ref.watch(singleStockPriceProvider(symbol));

    // Look up company name for display (e.g., "RELIANCE" -> "Reliance Industries")
    final companyName = StockConstants.companyNames[symbol] ?? symbol;

    // Safety guard: If quotes are not yet populated, render an empty box.
    if (quote == null) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
        // Tapping a stock row navigates to the Buy/Sell ticket pre-filled with this symbol.
        onTap: () => context.push('/order/$symbol'),
        borderRadius: BorderRadius.circular(12),
        child: FlashContainer(
          // Flash green if price increased, red if price decreased.
          direction: quote.direction,
          timestamp: quote.timestamp,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Left Column: Stock Symbol & Company Full Name
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

              // Right Column: Last Traded Price (LTP) & Live Change Indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Formatted currency (stored in paise, converted to ₹ format)
                  Text(
                    MoneyUtils.paiseToCurrency(quote.ltpPaise),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // Price change badge displaying "+₹12.50 (+0.44%)" in green/red
                  PriceChangeText(
                    changePaise: quote.changePaise,
                    changePercent: quote.changePercent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
