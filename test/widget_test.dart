import 'package:flutter_test/flutter_test.dart';

import 'package:evoting_mobile/config/app_config.dart';
import 'package:evoting_mobile/main.dart';
import 'package:evoting_mobile/services/session_storage_service.dart';

void main() {
  testWidgets('shows two-step verification auth screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        config: AppConfig.fromEnvironment(),
      ),
    );

    // Give the app a few frames to render (without waiting for all futures to complete)
    await tester.pump(const Duration(milliseconds: 100));

    // Verify two-step auth screen elements are rendered
    expect(find.text('Wallet Authentication'), findsWidgets);
    expect(find.text('Step 1: Register (VID + OTP)'), findsWidgets);
    expect(find.text('Step 2: Connect MetaMask Wallet'), findsWidgets);
  });

  test('SessionStorageService initializes empty', () async {
    final storage = SessionStorageService();
    final hasSession = await storage.hasExistingSession();
    expect(hasSession, false);

    final restored = await storage.restoreSession();
    expect(restored, isNull);
  });

  test('SessionStorageService can save and restore session', () async {
    final storage = SessionStorageService();
    await storage.saveSession(
      connectedAccount: '0x${'a' * 40}',
      chainId: '11155111',
    );

    final hasSession = await storage.hasExistingSession();
    expect(hasSession, true);

    final restored = await storage.restoreSession();
    expect(restored, isNotNull);
    expect(restored!.account, '0x${'a' * 40}');
  });
}
