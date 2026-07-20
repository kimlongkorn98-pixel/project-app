import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/main.dart';

class TestHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('ShoppingApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShoppingApp());
    await tester.pump();

    // Verify that the title is rendered
    expect(find.text('Discover Trends'), findsOneWidget);

    // Cancel pending timers from auto-scroll promo carousel
    await tester.pump(const Duration(seconds: 5));
  });
}
