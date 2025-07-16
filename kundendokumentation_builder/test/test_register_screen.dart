import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kundendokumentation_builder/features/auth/register_screen.dart';

class FakeFirestore extends Fake implements FirebaseFirestore {}

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  group('RegisterScreen Widget Test', () {
    testWidgets('zeigt Fehlermeldung bei bereits registrierter E-Mail', (
      WidgetTester tester,
    ) async {
      // Benutzer registrieren
      await mockAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      // Widget testen
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(auth: mockAuth, firestore: FakeFirestore()),
        ),
      );

      // Felder ausfüllen
      await tester.enterText(
        find.byKey(Key('registerEmailField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(Key('registerPasswordField')),
        'password123',
      );
      await tester.enterText(
        find.byKey(Key('registerNameField')),
        'Max Mustermann',
      );

      // Dropdowns auswählen
      await tester.tap(find.byKey(Key('registerRoleField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Techniker').last); // beliebiger Eintrag
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('registerAbteilungField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Instandhaltung').last);
      await tester.pumpAndSettle();

      // Registrierung auslösen
      await tester.tap(find.byKey(Key('registerButton')));
      await tester.pumpAndSettle();

      // Erwartung: Fehlermeldung in Snackbar
      expect(
        find.textContaining('E-Mail ist bereits registriert'),
        findsOneWidget,
      );
    });

    testWidgets('erfolgreiche Registrierung zeigt keine Fehlermeldung', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(auth: mockAuth, firestore: FakeFirestore()),
        ),
      );

      // Felder ausfüllen
      await tester.enterText(
        find.byKey(Key('registerEmailField')),
        'new@example.com',
      );
      await tester.enterText(
        find.byKey(Key('registerPasswordField')),
        'secure1234',
      );
      await tester.enterText(
        find.byKey(Key('registerNameField')),
        'Erika Musterfrau',
      );

      // Dropdowns auswählen
      await tester.tap(find.byKey(Key('registerRoleField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Admin').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('registerAbteilungField')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Produktion').last);
      await tester.pumpAndSettle();

      // Tippen auf "Registrieren"
      await tester.tap(find.byKey(Key('registerButton')));
      await tester.pumpAndSettle();

      // Erwartung: keine Fehlermeldung (kein Snackbar mit "fehlgeschlagen")
      expect(find.textContaining('Registrierung fehlgeschlagen'), findsNothing);
      expect(find.textContaining('Unbekannter Fehler'), findsNothing);
    });

    testWidgets('zeigt validierungs-Fehler bei fehlenden Pflichtfeldern', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(auth: mockAuth, firestore: FakeFirestore()),
        ),
      );

      // Nur E-Mail und Passwort eingeben
      await tester.enterText(
        find.byKey(Key('registerEmailField')),
        'valid@example.com',
      );
      await tester.enterText(
        find.byKey(Key('registerPasswordField')),
        '123456',
      );

      await tester.tap(find.byKey(Key('registerButton')));
      await tester.pumpAndSettle();

      // Erwartung: Validierungsfehler für Name, Rolle und Abteilung
      expect(
        find.text('Bitte gib deinen Vor- und Nachnamen ein'),
        findsOneWidget,
      );
    });
  });
}
