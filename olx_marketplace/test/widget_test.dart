// Basic smoke test: verifies the OLX app starts without crashing.
// Counter tests removed — the default counter widget no longer exists.

import 'package:flutter_test/flutter_test.dart';
import 'package:olx_marketplace/main.dart';

void main() {
  testWidgets('OlxApp starts without errors', (WidgetTester tester) async {
    // Build the app and allow one frame to render.
    await tester.pumpWidget(const OlxApp());

    // If we reach this point the app started without throwing.
    expect(tester.takeException(), isNull);
  });
}
