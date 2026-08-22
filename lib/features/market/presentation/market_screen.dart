import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/stock_constants.dart';
import 'providers/market_providers.dart';
import 'widgets/market_price_tile.dart';

/// The Live Prices Mimic screen (Feature 2).
///
/// Shows a continuously updating market overview surface for the 10 stocks.
/// Includes a Stress Mode toggle in the AppBar to switch tick rate to 50+ ticks/sec.
class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStressMode = ref.watch(stressModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Live Market'),
            Text(
              '10 Stocks • Real-time Feed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          // Stress mode toggle action button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              avatar: Icon(
                Icons.bolt,
                size: 16,
                color: isStressMode ? Colors.amber : AppColors.textMuted,
              ),
              label: Text(
                isStressMode ? '50+ Ticks/s' : 'Normal Feed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isStressMode ? FontWeight.bold : FontWeight.normal,
                  color: isStressMode ? Colors.amber : AppColors.textSecondary,
                ),
              ),
              selected: isStressMode,
              selectedColor: Colors.amber.withValues(alpha: 0.2),
              backgroundColor: AppColors.surfaceBackground,
              side: BorderSide(
                color: isStressMode ? Colors.amber : AppColors.border,
                width: 1,
              ),
              onSelected: (_) {
                ref.read(stressModeProvider.notifier).toggle();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stress mode status banner when active
          if (isStressMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.amber.withValues(alpha: 0.15),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Stress Mode Active: Emitting 50+ ticks/second overall',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // List of 10 market stocks
          Expanded(
            child: ListView.builder(
              itemCount: StockConstants.allSymbols.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final symbol = StockConstants.allSymbols[index];
                return MarketPriceTile(
                  key: ValueKey(symbol),
                  symbol: symbol,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
