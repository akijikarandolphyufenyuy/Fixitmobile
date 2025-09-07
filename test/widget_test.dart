// test/widget_test.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/main.dart'; // Import your main.dart where FixitApp is defined
import 'package:fixit/data/repositories/auth_repository.dart'; // Import AuthRepository

void main() {
  // Ensure test binding is initialized before any Firebase calls
  TestWidgetsFlutterBinding.ensureInitialized();

  // Get the *single instance* of your AuthRepository for the test suite.
  final AuthRepository authRepositoryInstance = AuthRepository.instance;

  setUpAll(() async {
    // Initialize Firebase once for all tests in this suite.
    await Firebase.initializeApp();

    // Ensure AuthRepository is initialized and ready before any test starts.
    // This awaits the same Future that your app's FutureBuilder awaits.
    await authRepositoryInstance.waitForInit();

    // No mocks — this test setup is specifically for interacting with real Firebase.
    // If you need to test offline behavior or specific mock scenarios,
    // you would create a MockAuthRepository and pass that instead.
  });

  // Example test: Verify initial app load and navigation to settings
  testWidgets('App initializes, displays home, and navigates to settings', (
    WidgetTester tester,
  ) async {
    // Run your app, explicitly passing the singleton AuthRepository instance.
    await tester.pumpWidget(FixitApp(authRepository: authRepositoryInstance));

    // The FutureBuilder in FixitApp will show a CircularProgressIndicator while
    // authRepositoryInstance.waitForInit() completes.
    // pumpAndSettle waits for all animations and futures to complete.
    // The 5-second duration is a safety net for network calls.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // --- Verify Home Page Content ---
    // Check for a text element expected on the HomePage (e.g., a welcome message).
    expect(find.text('Welcome back, Samuel!'), findsOneWidget);
    // Ensure the loading indicator is gone.
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // --- Navigate to Settings Page ---
    // Find the settings icon in the bottom navigation bar and tap it.
    // Assuming your bottom nav bar has a settings icon with type Icons.settings
    await tester.tap(find.byIcon(Icons.settings));
    // Wait for navigation and any new widgets to render.
    await tester.pumpAndSettle();

    // --- Verify Settings Page Content ---
    // Check for the AppBar title of the SettingsPage.
    expect(find.text('Settings'), findsOneWidget);
    // Check for other elements expected on the SettingsPage.
    expect(find.text('Account'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);

    // If you have a specific message after successful navigation, check for it.
    // For example, if your SettingsPage displays a profile name.
    // expect(find.text('User Profile'), findsOneWidget);
  });

  // You can add more tests here, for example:
  // testWidgets('Tapping on a job navigates to job details', (tester) async {
  //   // ... logic to get to the home page ...
  //   await tester.pumpWidget(FixitApp(authRepository: authRepositoryInstance));
  //   await tester.pumpAndSettle(const Duration(seconds: 5));
  //
  //   // Tap on the first job listed (adjust finder as needed)
  //   await tester.tap(find.text('Plumbing repair').first);
  //   await tester.pumpAndSettle();
  //
  //   // Verify that the job details page is displayed
  //   // expect(find.text('Job Details: Plumbing repair'), findsOneWidget);
  // });
}
