import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/stock_constants.dart';
import '../../../../core/utils/money_utils.dart';
import '../../../../core/widgets/price_change_text.dart';
import '../../../market/presentation/providers/market_providers.dart';

/// Modal bottom sheet allowing users to add stocks to a watchlist.
///
/// Displays all 10 available NSE stocks with their live prices.
/// Stocks already present in the target watchlist are marked as "Added" and disabled.
class StockPickerDialog extends ConsumerWidget {
  const StockPickerDialog({
    super.key,
    required this.watchlistId,
    required this.existingSymbols,
    required this.onStockSelected,
  });

  /// ID of the watchlist receiving the stock.
  final String watchlistId;

  /// List of stock symbols already in the watchlist.
  final List<String> existingSymbols;

  /// Callback when a stock is selected.
  final ValueChanged<String> onStockSelected;

  /// Displays the picker as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String watchlistId,
    required List<String> existingSymbols,
    required ValueChanged<String> onStockSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StockPickerDialog(
        watchlistId: watchlistId,
        existingSymbols: existingSymbols,
        onStockSelected: onStockSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read live price quotes snapshot
    final priceMap = ref.watch(marketPricesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal drag handle indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Stock to Watchlist',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // List of 10 available NSE stocks
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: StockConstants.allSymbols.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final symbol = StockConstants.allSymbols[index];
                    final companyName =
                        StockConstants.companyNames[symbol] ?? symbol;
                    final isAlreadyAdded = existingSymbols.contains(symbol);
                    final quote = priceMap[symbol];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      title: Text(
                        symbol,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isAlreadyAdded
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        companyName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (quote != null) ...[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  MoneyUtils.paiseToCurrency(quote.ltpPaise),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                PriceChangeText(
                                  changePaise: quote.changePaise,
                                  changePercent: quote.changePercent,
                                  fontSize: 11,
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (isAlreadyAdded)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceBackground,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text(
                                'Added',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: AppColors.accentBlue,
                              ),
                              onPressed: () {
                                onStockSelected(symbol);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$symbol added to watchlist'),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
