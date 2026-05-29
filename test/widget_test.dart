// Basic smoke test for Word Master.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:word_master/core/app_theme.dart';

void main() {
  testWidgets('App theme builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: Center(child: Text('Word Master'))),
      ),
    );

    expect(find.text('Word Master'), findsOneWidget);
  });
}
