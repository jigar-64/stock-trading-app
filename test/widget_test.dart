import 'package:flutter_test/flutter_test.dart';

import 'package:stock_trading/app/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const TradingApp());
    // Verify the app shell renders with the Market tab visible.
    expect(find.text('Market'), findsWidgets);
  });
}
