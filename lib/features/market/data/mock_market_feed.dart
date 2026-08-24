import 'dart:async';
import 'dart:math';

import '../../../core/constants/stock_constants.dart';
import '../domain/price_quote.dart';

/// Centralized, application-scoped mock market data feed.
///
/// Role in Architecture:
/// This feed is the SINGLE SOURCE OF TRUTH for all stock prices in the application.
/// It runs continuously in the background across tab navigation (Market, Watchlist, Holdings, Ticket).
///
/// Key Technical Characteristics:
/// 1. Application-scoped: Uses a single periodic timer, avoiding multiple competing timers per screen.
/// 2. Price Movements: Generates realistic random percentage fluctuations (±0.05% to ±0.5%).
/// 3. Money Precision: Computes all price changes in integer paise to avoid floating-point drift.
/// 4. Stress Test Support: Allows toggling tick intervals between normal (~500ms) and stress mode (~20ms / 50+ ticks/sec).
class MockMarketFeed {
  MockMarketFeed({
    Duration tickInterval = normalTickInterval,
  }) : _tickInterval = tickInterval {
    _initQuotes();
  }

  /// Default tick interval for realistic market simulation (~2 ticks/sec total).
  static const Duration normalTickInterval = Duration(milliseconds: 500);

  /// Stress test tick interval (~50+ ticks/sec total) for performance benchmarking.
  static const Duration stressTickInterval = Duration(milliseconds: 20);

  final Random _random = Random();
  Timer? _timer;
  Duration _tickInterval;

  /// Internal state store of all 10 stock quotes, indexed by symbol string.
  final Map<String, PriceQuote> _quotes = {};

  /// Broadcast controller emitting price updates to subscribers across the app.
  final _controller = StreamController<Map<String, PriceQuote>>.broadcast();

  /// Public broadcast stream emitting updated price quote maps.
  Stream<Map<String, PriceQuote>> get priceStream => _controller.stream;

  /// Gets a synchronous, unmodifiable snapshot of current quotes.
  Map<String, PriceQuote> get currentQuotes => Map.unmodifiable(_quotes);

  /// Gets the currently configured tick interval.
  Duration get tickInterval => _tickInterval;

  /// Returns true if the tick generator timer is currently running.
  bool get isRunning => _timer != null && _timer!.isActive;

  /// Populates initial starting quotes for all 10 NSE stocks from [StockConstants].
  void _initQuotes() {
    final now = DateTime.now();
    for (final symbol in StockConstants.allSymbols) {
      final initialPrice = StockConstants.startingPricesPaise[symbol] ?? 100000;
      _quotes[symbol] = PriceQuote(
        symbol: symbol,
        ltpPaise: initialPrice,
        previousClosePaise: initialPrice,
        changePaise: 0,
        changePercent: 0.0,
        direction: PriceDirection.flat,
        timestamp: now,
      );
    }
  }

  /// Starts emitting price ticks at the configured interval.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(_tickInterval, (_) => _generateTick());
  }

  /// Stops emitting price ticks.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Updates the tick interval (e.g. switching between Normal and Stress mode)
  /// and restarts the timer seamlessly if currently active.
  void setTickInterval(Duration interval) {
    if (_tickInterval == interval) return;
    _tickInterval = interval;
    if (isRunning) {
      start();
    }
  }

  /// Generates a single price tick for a randomly selected stock.
  ///
  /// Algorithm:
  /// 1. Pick 1 random stock from the 10 catalog stocks.
  /// 2. Compute a percentage delta factor (-0.5% to +0.5%).
  /// 3. Convert percentage delta to integer paise delta.
  /// 4. Clamp new price so it never drops below 1 Rupee (100 paise).
  /// 5. Calculate overall change and change percentage relative to previous close.
  /// 6. Determine direction (up/down/flat) for visual color flash animation.
  /// 7. Update internal quotes map and broadcast to subscribers.
  void _generateTick() {
    if (_quotes.isEmpty) return;

    // Select a random stock from the catalog
    final symbols = StockConstants.allSymbols;
    final symbol = symbols[_random.nextInt(symbols.length)];
    final currentQuote = _quotes[symbol];
    if (currentQuote == null) return;

    // Generate random percentage delta between -0.5% and +0.5%
    final deltaFactor = (_random.nextDouble() - 0.5) * 0.01;
    
    // Calculate integer paise change
    int priceDelta = (currentQuote.ltpPaise * deltaFactor).round();
    if (priceDelta == 0) {
      priceDelta = _random.nextBool() ? 100 : -100; // Minimum tick step of ₹1.00 (100 paise)
    }

    // New price in paise, clamped to minimum ₹1.00
    final newLtpPaise = max(100, currentQuote.ltpPaise + priceDelta);
    final changePaise = newLtpPaise - currentQuote.previousClosePaise;
    final changePercent =
        (changePaise / currentQuote.previousClosePaise) * 100.0;

    // Determine direction for UI flash animation
    final PriceDirection direction;
    if (newLtpPaise > currentQuote.ltpPaise) {
      direction = PriceDirection.up;
    } else if (newLtpPaise < currentQuote.ltpPaise) {
      direction = PriceDirection.down;
    } else {
      direction = PriceDirection.flat;
    }

    // Update quote record with fresh timestamp
    _quotes[symbol] = currentQuote.copyWith(
      ltpPaise: newLtpPaise,
      changePaise: changePaise,
      changePercent: changePercent,
      direction: direction,
      timestamp: DateTime.now(),
    );

    // Broadcast updated state snapshot
    _controller.add(Map.unmodifiable(_quotes));
  }

  /// Cancels timer and closes stream controller on disposal.
  void dispose() {
    stop();
    _controller.close();
  }
}
