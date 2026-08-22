# 📈 021 Trading App — Realtime Flutter Stock Trading Simulator

A production-grade, highly performant stock trading application built with **Flutter**, **Riverpod**, **GoRouter**, and **SharedPreferences**.

Designed for zero-jank real-time performance (60 FPS under 50+ ticks/sec stress mode), financial precision (integer paise math to eliminate floating-point drift), and persistent state across app restarts.

---

## 🚀 Quick Start (Zero Setup Required)

Per assignment requirements, this app requires **no extra native setup, code generation, or backend setup**.

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run the application
flutter run
```

*Note: Runs on Android, iOS, Windows, macOS, Linux, and Web out of the box.*

---

## 🛠️ Architecture & Tech Stack

The application follows a **Pragmatic Feature-first Clean Architecture** (`Presentation -> Providers -> Domain -> Data`):

```
lib/
├── app/
│   ├── theme/          # Dark trading theme (AppColors, typography, inputs)
│   ├── app.dart        # MaterialApp.router configuration
│   └── router.dart     # GoRouter with StatefulShellRoute bottom navigation
├── core/
│   ├── constants/      # StockConstants (10 NSE stocks, starting prices in paise)
│   ├── storage/        # SharedPreferences provider setup
│   ├── utils/          # MoneyUtils (Paise currency & Indian comma formatting)
│   └── widgets/        # Reusable FlashContainer, PriceChangeText, EmptyState
└── features/
    ├── market/         # Feature 2: Live Market Feed & Stress Mode
    ├── watchlist/      # Feature 1: Multi-Watchlists with Drag Reorder
    ├── order/          # Feature 3: Buy/Sell Ticket with Live Execution LTP
    ├── portfolio/      # Feature 4: Realtime Holdings with Derived P&L & Sorting
    └── wallet/         # Margin Balance State Management
```

### Key Libraries
- **State Management**: `flutter_riverpod` (v2.6.1) — Fine-grained reactive subscriptions for zero-jank updates.
- **Routing**: `go_router` (v14.8.1) — Declarative routing with `StatefulShellRoute` for smooth tab navigation.
- **Persistence**: `shared_preferences` (v2.5.5) — Native JSON serialization with zero native dependency issues.
- **UUID**: `uuid` (v4.6.0) — Unique entity generation for watchlists and orders.

---

## 🌟 4 Core Features

### 1. Watchlist (Feature 1)
- **Multi-Watchlist Support**: Create, rename, and delete custom watchlists.
- **Stock Picker**: Modal bottom sheet showing all 10 NSE stocks with live prices (disables already added symbols).
- **Drag-to-Reorder**: Reorder stocks smoothly via `ReorderableListView`.
- **Symbol-Based Price Identity**: Reordering symbols alters position indices but preserves symbol string identity (`singleStockPriceProvider(symbol)`). An `INFY` tick will **never** appear on a `RELIANCE` row!
- **Persistence**: All watchlists, names, and stock orders persist across app restarts.

### 2. Live Prices Mimic (Feature 2)
- **Centralized Feed**: `MockMarketFeed` runs an application-scoped tick generator simulating random price movements (±0.05% to ±0.5%).
- **Green/Red Flash**: 350ms `AnimationController` smoothly flashes tile backgrounds on price changes.
- **50+ Ticks/sec Stress Mode**: AppBar toggle button switches tick rate from normal (~500ms) to stress test mode (~20ms).
- **Fine-Grained Rebuilds**: When TCS ticks, only the TCS widget rebuilds. RELIANCE and INFY widgets remain completely untouched.

### 3. Buy & Sell Ticket (Feature 3)
- **Pre-filled Symbol**: Opens via `/order/:symbol` pre-filled with the selected stock.
- **Live LTP & Order Value**: Real-time projected order value (`quantity × current LTP`) updates continuously on live ticks and keystrokes.
- **Pure Validation**: `OrderValidator` enforces non-fractional, positive integer quantities, margin balance checks (Buy), and held quantity checks (Sell).
- **Execution-Time Snapshot**: Reads current LTP directly from the provider at the exact moment of order submission to prevent race conditions.
- **Order Receipt**: Navigates to `OrderConfirmationScreen` detailing executed price, order value, and updated wallet balance.

### 4. Portfolio Holdings (Feature 4)
- **Realtime P&L**: P&L is derived dynamically on the fly (`quantity × liveLTP - investedPaise`), never hardcoded or stored.
- **Aggregate Summary**: Header card displaying total invested, total current value, and total portfolio P&L (₹ and %).
- **Dynamic Sorting**: Sort by **P&L ↓** (default), **Symbol A-Z**, or **Value ↓**. Sorted order updates dynamically as live ticks arrive.
- **Weighted Average Cost**: Purchases update average cost via integer paise formula `(existingQty × existingAvg + newQty × executionPrice) ~/ totalQty`.
- **Sell-to-Zero Cleanup**: Selling all held shares cleanly removes position from portfolio.

---

## 🧮 Money Handling & Paise Precision

To completely eliminate floating-point arithmetic errors (e.g. `0.1 + 0.2 = 0.30000000000000004`), **all financial values are stored and calculated in integer minor units (paise)**.

- **₹2,845.35** is stored as `284535` (`int`).
- **₹1,00,000.00** wallet balance is stored as `10000000` (`int`).
- Formatters in `MoneyUtils` convert paise into Indian currency format (lakh/crore comma system): `284535` ➡️ `₹2,845.35`.

---

## 📊 Stock Catalog (10 NSE Stocks)

| Symbol | Company Name | Starting Price (Paise) | Starting Price (₹) |
|---|---|---|---|
| **RELIANCE** | Reliance Industries | `284535` | ₹2,845.35 |
| **TCS** | Tata Consultancy | `392080` | ₹3,920.80 |
| **INFY** | Infosys | `148625` | ₹1,486.25 |
| **HDFCBANK** | HDFC Bank | `163290` | ₹1,632.90 |
| **ICICIBANK** | ICICI Bank | `121475` | ₹1,214.75 |
| **SBIN** | State Bank of India | `83150` | ₹831.50 |
| **ITC** | ITC Limited | `46820` | ₹468.20 |
| **LT** | Larsen & Toubro | `346700` | ₹3,467.00 |
| **BHARTIARTL** | Bharti Airtel | `168945` | ₹1,689.45 |
| **AXISBANK** | Axis Bank | `115530` | ₹1,155.30 |

---

## 🧪 Automated Testing

Run unit & widget tests:
```bash
flutter test
```

### Test Suite (22/22 Passing)
- `test/core/utils/money_utils_test.dart`: Currency formatting, Indian commas, paise math, weighted average cost.
- `test/features/order/domain/order_validator_test.dart`: Pure domain validation for quantity, margin balance, and sell holdings.
- `test/features/portfolio/domain/pnl_calculation_test.dart`: Invested calculation, derived P&L %, sorting comparators.
- `test/features/watchlist/stale_tick_test.dart`: **Critical Stale-Tick Reorder Test** verifying symbol-based price identity.
- `test/widget_test.dart`: App rendering test with SharedPreferences mock and `ProviderScope` override.

---

## 🎥 Walkthrough Video

A short walkthrough video demonstrating all 4 features end-to-end is attached to the submission.

---

## 📝 Commit History Highlights

- `0faf1c0` `chore: initialize flutter project with architecture and dependencies`
- `691f309` `feat: add trading domain models and money handling`
- `5495ac6` `fix(android): disable kotlin incremental compilation to prevent build cache lock on windows`
- `6bf4d49` `feat: add local persistence repositories`
- `46e72e3` `feat: implement centralized mock market feed`
- `723e0ca` `feat: add realtime market overview with flash animations`
- `294fc9e` `docs: add comprehensive inline comments and architectural docstrings`
- `d88ad46` `feat: implement persistent watchlists with drag reorder`
- `5692e60` `feat: implement wallet provider and order validation`
- `7147a4f` `feat: implement buy/sell ticket with live LTP and execution`
- `2245ca5` `feat: add realtime portfolio holdings with live P&L and sorting`
- `6cc6288` `test: add unit tests for money, validation, and portfolio logic`
- `2f63d2c` `perf: optimize rebuilds and verify stress mode performance`
- `104b09b` `fix: handle edge cases and polish UI states`
- `README.md` `docs: add README with architecture, setup, and walkthrough`
