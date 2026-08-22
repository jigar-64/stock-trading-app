import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stock_trading/app/app.dart';
import 'package:stock_trading/core/storage/storage_providers.dart';

void main() {
  testWidgets('TradingApp renders without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const TradingApp(),
      ),
    );

    await tester.pump();
    expect(find.text('021 TRADING'), findsWidgets);
  });
}
