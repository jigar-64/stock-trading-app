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
/// Modern Design Highlights:
/// - Avatar Icon badge with initial symbol letter
/// - Crisp typography and clean spacing
/// - RepaintBoundary for isolated GPU layer repaints
/// - Fine-grained Riverpod singleStockPriceProvider selector for zero-jank selective rebuilds
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

    // Avatar initial letter
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Stock Ticker Avatar Badge
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.elevatedSurface,
                          AppColors.surfaceBackground,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
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
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Left Column: Stock Symbol & Company Full Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          quote.symbol,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.3,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          companyName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
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
                      Text(
                        MoneyUtils.paiseToCurrency(quote.ltpPaise),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                      ),
                      const SizedBox(height: 4),
                      PriceChangeText(
                        changePaise: quote.changePaise,
                        changePercent: quote.changePercent,
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
