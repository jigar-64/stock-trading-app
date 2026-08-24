import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_theme.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/market/presentation/market_screen.dart';
import '../features/order/presentation/order_ticket_screen.dart';
import '../features/order/presentation/order_confirmation_screen.dart';
import '../features/portfolio/presentation/holdings_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/watchlist/presentation/watchlist_screen.dart';

/// The main app router configuration.
///
/// Routes:
///   /splash      → Animated Branding Splash Screen
///   /login       → Modern Auth & Quick 1-Tap Demo Login Screen
///   /market      → Live Prices Mimic (Feature 2)
///   /watchlists  → Watchlist Management (Feature 1)
///   /holdings    → Portfolio Holdings (Feature 4)
///   /profile     → Account Profile & Order History
///   /order/:symbol → Buy/Sell Ticket (Feature 3)
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash Route
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Login Route
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Bottom navigation shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/market',
              builder: (context, state) => const MarketScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/watchlists',
              builder: (context, state) => const WatchlistScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/holdings',
              builder: (context, state) => const HoldingsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Order ticket — standalone route (not in bottom nav)
    GoRoute(
      path: '/order/:symbol',
      builder: (context, state) {
        final symbol = state.pathParameters['symbol'] ?? '';
        return OrderTicketScreen(symbol: symbol);
      },
    ),

    // Order confirmation — standalone route
    GoRoute(
      path: '/order-confirmation',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return OrderConfirmationScreen(
          order: extra['order'],
          remainingBalancePaise: extra['remainingBalancePaise'] as int,
        );
      },
    ),
  ],
);

/// The app shell with bottom navigation bar.
class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            activeIcon: Icon(Icons.show_chart, color: AppColors.accentIndigo),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            activeIcon: Icon(Icons.list_alt, color: AppColors.accentIndigo),
            label: 'Watchlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            activeIcon: Icon(
              Icons.account_balance_wallet,
              color: AppColors.accentIndigo,
            ),
            label: 'Holdings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(
              Icons.person,
              color: AppColors.accentIndigo,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
