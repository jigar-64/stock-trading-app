import 'dart:async';
import 'dart:math';

import '../../../core/constants/stock_constants.dart';
import '../domain/price_quote.dart';

/// Centralized, application-scoped mock market data feed.
///
/// Simulates continuous live stock price movements for the 10 fixed stocks.
/// Generates realistic tick updates (small percentage fluctuations) and supports
/// switching between normal (~2 ticks/sec overall) and stress test mode (50+ ticks/sec).
class MockMarketFeed {
  MockMarketFeed({
    this._tickInterval = normalTickInterval,
  }) {
    _initQuotes();
  }

  /// Default tick interval for realistic market behavior (~500ms between ticks).
  static const Duration normalTickInterval = Duration(milliseconds: 500);

  /// Stress test tick interval (~20ms between ticks, 50+ ticks/sec total).
  static const Duration stressTickInterval = Duration(milliseconds: 20);

  final Random _random = Random();
  Timer? _timer;
  Duration _tickInterval;

  /// Current state of all stock quotes, keyed by stock symbol.
  final Map<String, PriceQuote> _quotes = {};

  /// Controller emitting continuous price updates (either full map or single quote).
  final _controller = StreamController<Map<String, PriceQuote>>.broadcast();

  /// Broadcast stream of price quote map updates.
  Stream<Map<String, PriceQuote>> get priceStream => _controller.stream;

  /// Gets the current snapshot of all stock quotes.
  Map<String, PriceQuote> get currentQuotes => Map.unmodifiable(_quotes);

  /// Current tick interval.
  Duration get tickInterval => _tickInterval;

  /// Whether the feed is currently active and emitting ticks.
  bool get isRunning => _timer != null && _timer!.isActive;

  /// Initializes starting quotes for all 10 stocks.
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

  /// Starts emitting price ticks.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(_tickInterval, (_) => _generateTick());
  }

  /// Stops the tick generator.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Sets a new tick interval and restarts the timer if running.
  void setTickInterval(Duration interval) {
    if (_tickInterval == interval) return;
    _tickInterval = interval;
    if (isRunning) {
      start();
    }
  }

  /// Generates a single price tick for a randomly chosen stock.
  void _generateTick() {
    if (_quotes.isEmpty) return;

    // Pick a random stock symbol
    final symbols = StockConstants.allSymbols;
    final symbol = symbols[_random.nextInt(symbols.length)];
    final currentQuote = _quotes[symbol];
    if (currentQuote == null) return;

    // Generate a small percentage delta (-0.5% to +0.5%)
    // Random double between -0.005 and +0.005
    final deltaFactor = (_random.nextDouble() - 0.5) * 0.01;
    
    // Ensure at least 1 paise change if deltaFactor != 0
    int priceDelta = (currentQuote.ltpPaise * deltaFactor).round();
    if (priceDelta == 0) {
      priceDelta = _random.nextBool() ? 100 : -100; // ±1 Rupee (100 paise) minimum tick
    }

    // New price (clamped to at least 1 Rupee = 100 paise)
    final newLtpPaise = max(100, currentQuote.ltpPaise + priceDelta);
    final changePaise = newLtpPaise - currentQuote.previousClosePaise;
    final changePercent =
        (changePaise / currentQuote.previousClosePaise) * 100.0;

    final PriceDirection direction;
    if (newLtpPaise > currentQuote.ltpPaise) {
      direction = PriceDirection.up;
    } else if (newLtpPaise < currentQuote.ltpPaise) {
      direction = PriceDirection.down;
    } else {
      direction = PriceDirection.flat;
    }

    _quotes[symbol] = currentQuote.copyWith(
      ltpPaise: newLtpPaise,
      changePaise: changePaise,
      changePercent: changePercent,
      direction: direction,
      timestamp: DateTime.now(),
    );

    // Emit updated copy of quotes
    _controller.add(Map.unmodifiable(_quotes));
  }

  /// Disposes resources.
  void dispose() {
    stop();
    _controller.close();
  }
}
