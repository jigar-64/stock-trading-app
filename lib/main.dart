import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/storage/storage_providers.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences before mounting the widget tree
  final prefs = await SharedPreferences.getInstance();

  runApp(
    // Override the sharedPreferencesProvider with the initialized instance
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TradingApp(),
    ),
  );
}
