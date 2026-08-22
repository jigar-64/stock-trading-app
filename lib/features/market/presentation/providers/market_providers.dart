import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_market_feed.dart';
import '../../domain/price_quote.dart';

/// Provider for the single, application-scoped [MockMarketFeed] instance.
final mockMarketFeedProvider = Provider<MockMarketFeed>((ref) {
  final feed = MockMarketFeed();
  feed.start();
  ref.onDispose(() {
    feed.dispose();
  });
  return feed;
});

/// StateNotifier that manages stress mode toggle state (normal vs 50+ ticks/sec).
class StressModeNotifier extends StateNotifier<bool> {
  StressModeNotifier(this._feed) : super(false);

  final MockMarketFeed _feed;

  /// Toggles stress mode on or off.
  void toggle() {
    state = !state;
    _feed.setTickInterval(
      state
          ? MockMarketFeed.stressTickInterval
          : MockMarketFeed.normalTickInterval,
    );
  }

  /// Sets stress mode explicitly.
  void setStressMode(bool enabled) {
    if (state == enabled) return;
    state = enabled;
    _feed.setTickInterval(
      enabled
          ? MockMarketFeed.stressTickInterval
          : MockMarketFeed.normalTickInterval,
    );
  }
}

/// Provider for stress test mode state.
final stressModeProvider =
    StateNotifierProvider<StressModeNotifier, bool>((ref) {
  final feed = ref.watch(mockMarketFeedProvider);
  return StressModeNotifier(feed);
});

/// StreamProvider exposing the live market quotes map (`Map<String, PriceQuote>`).
///
/// Updates continuously as ticks arrive from the [MockMarketFeed].
final marketPriceMapStreamProvider =
    StreamProvider<Map<String, PriceQuote>>((ref) {
  final feed = ref.watch(mockMarketFeedProvider);
  return feed.priceStream;
});

/// Notifier providing a synchronous, reactive map of all market quotes (`Map<String, PriceQuote>`).
class MarketPricesNotifier extends StateNotifier<Map<String, PriceQuote>> {
  MarketPricesNotifier(this._feed) : super(_feed.currentQuotes) {
    _subscription = _feed.priceStream.listen((updatedMap) {
      state = updatedMap;
    });
  }

  final MockMarketFeed _feed;
  late final StreamSubscription<Map<String, PriceQuote>> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Provider for the synchronous, reactive market prices map.
final marketPricesProvider =
    StateNotifierProvider<MarketPricesNotifier, Map<String, PriceQuote>>((ref) {
  final feed = ref.watch(mockMarketFeedProvider);
  return MarketPricesNotifier(feed);
});

/// Fine-grained provider for a SINGLE stock symbol's price quote.
///
/// UI widgets subscribe to this provider with their symbol string:
/// `ref.watch(singleStockPriceProvider('RELIANCE'))`
///
/// When a tick arrives for TCS, widgets watching RELIANCE do NOT rebuild!
final singleStockPriceProvider = Provider.family<PriceQuote?, String>((ref, symbol) {
  final priceMap = ref.watch(marketPricesProvider);
  return priceMap[symbol];
});
