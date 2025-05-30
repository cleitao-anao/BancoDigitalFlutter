// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/models/user_profile.dart';

class MockAuthService extends AuthService {
  bool _isLoggedIn = false;

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  Future<UserProfile> login(String email, String password) async {
    _isLoggedIn = true;
    final now = DateTime.now();
    return UserProfile(
      id: 'mock-user-id',
      email: email,
      fullName: 'Test User',
      phone: null,
      createdAt: now,
      updatedAt: now,
    );
  }
}

void main() {
  testWidgets('App shows login screen when not logged in', (tester) async {
    // Setup
    final authService = MockAuthService();
    
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>(
            create: (_) => authService,
          ),
          Provider<http.Client>(
            create: (_) => http.Client(),
          ),
        ],
        child: const MaterialApp(
          home: MyApp(),
        ),
      ),
    );

    // Verify login screen is shown
    expect(find.text('Banco Digital'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
    expect(find.text('ENTRAR'), findsOneWidget);
  });

  testWidgets('Login with valid credentials', (tester) async {
    // Setup
    final authService = MockAuthService();
    
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>(
            create: (_) => authService,
          ),
          Provider<http.Client>(
            create: (_) => http.Client(),
          ),
        ],
        child: const MaterialApp(
          home: MyApp(),
        ),
      ),
    );

    // Fill in email and password
    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password');
    
    // Tap the login button
    await tester.tap(find.text('ENTRAR'));
    await tester.pumpAndSettle();

    // Verify that we're on the home screen
    expect(find.text('Meu Banco'), findsOneWidget);
  });
}
