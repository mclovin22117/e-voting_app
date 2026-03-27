// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:evoting_mobile/config/app_config.dart';
import 'package:evoting_mobile/main.dart';

void main() {
  testWidgets('shows Phase 0 auth journey options', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        config: AppConfig.fromEnvironment(),
      ),
    );

    expect(find.text('Choose Journey'), findsOneWidget);
    expect(find.text('Continue as Voter'), findsOneWidget);
    expect(find.text('Continue as Admin'), findsOneWidget);
  });
}
