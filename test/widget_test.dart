import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nounou_express/main.dart';

void main() {
  setUpAll(() {
    // Prevent google_fonts from making HTTP requests in tests,
    // which would leave pending timers and fail the test suite.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NounouExpressApp()));
    // Drain flutter_animate timers and any other pending work.
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
