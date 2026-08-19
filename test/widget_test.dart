import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/main.dart';
import 'package:shopping_app/providers/app_state.dart';
import 'package:shopping_app/screens/auth_screen.dart';
import 'package:shopping_app/widgets/custom_search_bar.dart';

class TestHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('ShoppingApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShoppingApp());
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.text('Try demo account'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    // Verify that login opens the storefront.
    expect(find.text('Discover Trends'), findsOneWidget);

    // Cancel pending timers from auto-scroll promo carousel
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('registration creates an authenticated account', (tester) async {
    final state = AppState();
    await tester.pumpWidget(MaterialApp(home: AuthScreen(state: state)));

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name'),
      'Jamie Rivera',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
      'jamie@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'Password123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'Password123',
    );
    await tester.tap(find.text('Create account'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(state.isAuthenticated, isTrue);
    expect(state.currentUserName, 'Jamie Rivera');
    expect(state.currentUserEmail, 'jamie@example.com');

    state.signOut();
    expect(state.isAuthenticated, isFalse);
  });

  testWidgets('search shows matching product suggestions', (tester) async {
    String? selectedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomSearchBar(
            suggestions: const [
              'Apple iPad Pro',
              'Adidas Ultraboost',
              'Nike Air Max',
              'Bose Speaker',
              'Sony Headphones',
            ],
            onChanged: (value) => selectedValue = value,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'a');
    await tester.pumpAndSettle();

    expect(find.text('Apple iPad Pro'), findsOneWidget);
    expect(find.text('Adidas Ultraboost'), findsOneWidget);
    expect(find.text('Nike Air Max'), findsNothing);
    expect(find.text('Sony Headphones'), findsNothing);

    await tester.tap(find.text('Apple iPad Pro'));
    await tester.pumpAndSettle();
    expect(selectedValue, 'Apple iPad Pro');

    await tester.enterText(find.byType(TextField), 'b');
    await tester.pumpAndSettle();
    expect(find.text('Bose Speaker'), findsOneWidget);
    expect(find.text('Apple iPad Pro'), findsNothing);
  });
}
