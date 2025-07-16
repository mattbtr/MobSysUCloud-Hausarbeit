import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:kundendokumentation_builder/features/auth/login_screen.dart';
import 'package:kundendokumentation_builder/features/auth/register_screen.dart';

void main() {
  group('LoginScreen', () {
    // Erfolgreicher Login
    testWidgets('Login funktioniert mit gültigen Zugangsdaten', (
      WidgetTester tester,
    ) async {
      // Benutzer vorbereiten
      final mockUser = MockUser(
        isAnonymous: false,
        email: 'test@example.com',
        uid: 'user123',
      );
      final mockAuth = MockFirebaseAuth(mockUser: mockUser);

      // Benutzer registrieren
      await mockAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'securePwd',
      );

      await tester.pumpWidget(MaterialApp(home: LoginScreen(auth: mockAuth)));

      await tester.enterText(
        find.byKey(const ValueKey('emailField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('passwordField')),
        'securePwd',
      );
      await tester.tap(find.byKey(const ValueKey('loginButton')));
      await tester.pumpAndSettle();

      // Kein Fehler-Snackbar sollte erscheinen
      expect(find.textContaining('Login failed'), findsNothing);
    });

    // Fehlerhafter Login
    testWidgets('Login zeigt Fehler bei ungültigen Zugangsdaten', (
      WidgetTester tester,
    ) async {
      final mockAuth = MockFirebaseAuth(); // Kein zuvor registrierter Benutzer

      await tester.pumpWidget(MaterialApp(home: LoginScreen(auth: mockAuth)));

      await tester.enterText(
        find.byKey(const ValueKey('emailField')),
        'wrong@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('passwordField')),
        'wrongpassword',
      );
      await tester.tap(find.byKey(const ValueKey('loginButton')));
      await tester.pumpAndSettle();

      // Fehler sollte angezeigt werden
      expect(find.textContaining('Login failed'), findsOneWidget);
    });

    // Navigationslink zur Registrierung
    testWidgets('Navigiert zur RegisterScreen bei Klick', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: LoginScreen(auth: MockFirebaseAuth())),
      );

      // Klick auf "Noch kein Konto? Jetzt registrieren."
      await tester.tap(find.text('Noch kein Konto? Jetzt registrieren.'));
      await tester.pumpAndSettle();

      // Erwartung: RegisterScreen wird geladen (überprüft z. B. anhand eines bekannten Textes oder Widgets)
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    // Leeres Passwort oder E-Mail (optional, falls du validierst)
    testWidgets('Login mit leerem Passwort oder E-Mail zeigt Fehler', (
      WidgetTester tester,
    ) async {
      final mockAuth = MockFirebaseAuth();

      await tester.pumpWidget(MaterialApp(home: LoginScreen(auth: mockAuth)));

      await tester.enterText(find.byKey(ValueKey('emailField')), '');
      await tester.enterText(find.byKey(ValueKey('passwordField')), '');
      await tester.tap(find.byKey(ValueKey('loginButton')));
      await tester.pumpAndSettle();

    });
  });
}
