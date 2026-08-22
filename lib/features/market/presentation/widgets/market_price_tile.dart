import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/stock_constants.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/flash_container.dart';
import '../../../../core/widgets/price_change_text.dart';
import '../providers/market_providers.dart';

/// A single stock tile in the Live Prices Mimic view.
///
/// Listens EXCLUSIVELY to its specific stock symbol via [singleStockPriceProvider].
/// When a tick arrives for TCS, widgets watching RELIANCE do NOT rebuild!
class MarketPriceTile extends ConsumerWidget {
  const MarketPriceTile({
    super.key,
    required this.symbol,
  });

  /// Stock symbol for this row (e.g., "RELIANCE").
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fine-grained selector: subscribes ONLY to this stock symbol's price quote
    final quote = ref.watch(singleStockPriceProvider(symbol));
    final companyName = StockConstants.companyNames[symbol] ?? symbol;

    if (quote == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => context.push('/order/$symbol'),
        borderRadius: BorderRadius.circular(12),
        child: FlashContainer(
          direction: quote.direction,
          timestamp: quote.timestamp,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Symbol & Company Name
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

              // LTP & Live Change
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
            ],
          ),
        ),
      ),
    );
  }
}
