import 'package:flutter_test/flutter_test.dart';

import 'package:hanyu_tong/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HanyuTongApp());

    // Verify the app builds without crashing.
    expect(find.byType(HanyuTongApp), findsOneWidget);
  });
}
