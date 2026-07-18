import 'package:flutter_test/flutter_test.dart';

import 'package:collabsy/app/app.dart';

void main() {
  testWidgets('Collabsy app loads successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const CollabsyApp(),
    );

    // Verify the app starts without throwing.
    expect(find.byType(CollabsyApp), findsOneWidget);
  });
}