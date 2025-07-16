import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';

import 'package:kundendokumentation_builder/features/profile/profile_screen.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('ProfileScreen', () {
    late FakeFirebaseFirestore firestore;
    // ignore: unused_local_variable
    late MockFirebaseAuth auth;
    late MockUser mockUser;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      mockUser = MockUser(uid: 'user123', email: 'test@example.com');
      auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      await firestore.collection('users').doc(mockUser.uid).set({
        'name': 'Max Mustermann',
        'email': 'max@firma.tld',
        'role': 'Techniker',
        'department': 'Instandhaltung',
      });
    });

    testWidgets('zeigt Benutzerdaten korrekt an', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ProfileScreen()));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Max Mustermann'), findsOneWidget);
      expect(find.text('max@firma.tld'), findsOneWidget);
      expect(find.text('Rolle: Techniker'), findsOneWidget);
      expect(find.text('Abteilung: Instandhaltung'), findsOneWidget);
    });

    testWidgets('zeigt Ladeindikator bei Verbindungsaufbau', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ProfileScreen()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('zeigt Dialog bei Klick auf Passwort ändern', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Passwort ändern'));
      await tester.pumpAndSettle();

      expect(find.text('Passwort ändern'), findsOneWidget);
      expect(find.textContaining('implementiert'), findsOneWidget);
    });

    testWidgets('führt Logout durch und navigiert zur Startseite', (
      WidgetTester tester,
    ) async {
      final navObserver = MockNavigatorObserver();

      final mockUser = MockUser(uid: 'user123', email: 'test@example.com');
      // ignore: unused_local_variable
      final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(),
          navigatorObservers: [navObserver],
          routes: {
            '/': (_) => const Placeholder(), // Zielroute für redirect
          },
        ),
      );

      await tester.pumpAndSettle();

      // Tippe auf "Abmelden"
      await tester.tap(find.widgetWithText(ListTile, 'Abmelden'));
      await tester.pumpAndSettle();

      // Bestätige durch das Vorhandensein der Placeholder-Startseite
      expect(find.byType(Placeholder), findsOneWidget);
    });


  });
}
