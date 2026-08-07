import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ridermate/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Suppress network image errors in headless test environment
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('NetworkImageLoadException') ||
          details.toString().contains('HTTP request failed')) {
        return; // Suppress expected test environment network errors
      }
      originalOnError?.call(details);
    };

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: const RiderMateApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(RiderMateApp), findsOneWidget);

    // Restore error handler
    FlutterError.onError = originalOnError;
  });
}
