import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

/// Root application widget.
///
/// Configures the [MaterialApp.router] with the app's dark trading theme
/// and GoRouter navigation.
class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '021 Trading App',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
