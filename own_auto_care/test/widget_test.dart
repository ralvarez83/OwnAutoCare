import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:own_auto_care/presentation/screens/welcome/welcome_screen.dart';
import 'package:own_auto_care/secrets.dart';

import 'fakes/fake_google_drive_provider.dart';

void main() {
  testWidgets('WelcomeScreen: pressing injected auth button navigates', (WidgetTester tester) async {
    final fakeProvider = FakeGoogleDriveProvider();

    await tester.pumpWidget(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(
              googleDriveProvider: fakeProvider,
              // Inject a simple button that calls the onAuthenticated callback
              // so we avoid platform views or external scripts in tests.
              authButtonBuilder: (provider, onAuthenticated) => ElevatedButton(
                onPressed: onAuthenticated,
                child: const Text('Test Sign In'),
              ),
            ),
        '/vehicle-list': (context) => const Scaffold(body: Center(child: Text('Vehicle List'))),
      },
    ));

    // Verify welcome title is present
    expect(find.text('🚗 OwnAutoCare'), findsOneWidget);

    // Our injected button should be visible
    expect(find.text('Test Sign In'), findsOneWidget);

    // Tap it and verify we navigated to the vehicle list screen
    await tester.tap(find.text('Test Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Vehicle List'), findsOneWidget);
  });
}
