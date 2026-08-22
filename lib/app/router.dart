import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_theme.dart';

// Placeholder screens — will be replaced in future commits
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

/// The main app router configuration.
///
/// Routes:
///   /market      → Live Prices Mimic (Feature 2)
///   /watchlists  → Watchlist Management (Feature 1)
///   /holdings    → Portfolio Holdings (Feature 4)
///   /order/:symbol → Buy/Sell Ticket (Feature 3)
final GoRouter appRouter = GoRouter(
  initialLocation: '/market',
  routes: [
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
              builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Market'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/watchlists',
              builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Watchlists'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/holdings',
              builder: (context, state) =>
                  const _PlaceholderScreen(title: 'Holdings'),
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
        return _PlaceholderScreen(title: 'Order: $symbol');
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
            activeIcon: Icon(Icons.show_chart, color: AppColors.accentBlue),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            activeIcon: Icon(Icons.list_alt, color: AppColors.accentBlue),
            label: 'Watchlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            activeIcon: Icon(
              Icons.account_balance_wallet,
              color: AppColors.accentBlue,
            ),
            label: 'Holdings',
          ),
        ],
      ),
    );
  }
}
