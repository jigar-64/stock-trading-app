import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // ProviderScope is the root of all Riverpod providers.
    // It must wrap the entire app so that providers are application-scoped.
    const ProviderScope(
      child: TradingApp(),
    ),
  );
}
