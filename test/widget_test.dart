import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paynote/main.dart';

void main() {
  testWidgets('PayNote app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PayNoteApp());

    // Verify that the app loads
    expect(find.text('PayNote'), findsOneWidget);
  });
}
