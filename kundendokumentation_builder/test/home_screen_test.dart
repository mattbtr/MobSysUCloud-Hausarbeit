import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:kundendokumentation_builder/features/home/home_screen.dart';
// ignore: unused_import
import 'package:kundendokumentation_builder/features/home/camera_screen.dart';

void main() {
  group('HomeScreen', () {
    late FakeFirebaseFirestore firestore;
    // ignore: unused_local_variable
    late MockFirebaseAuth mockAuth;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      final mockUser = MockUser(uid: 'abc123', email: 'test@example.com');
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      // Nutzer-Dokument anlegen
      await firestore.collection('users').doc('abc123').set({
        'name': 'Max Mustermann',
      });
    });

    testWidgets('zeigt Begrüßung mit Nutzername', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home:
              HomeScreen(), // Der Screen nutzt intern FirebaseAuth / Firestore
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Hallo, Max Mustermann'), findsOneWidget);
    });

    testWidgets('zeigt und testet alle Navigationsbuttons', (tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      await tester.pumpAndSettle();

      expect(find.text('Berichte Übersicht'), findsOneWidget);
      expect(find.text('Bericht erstellen'), findsOneWidget);
      expect(find.text('Datenupload'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Kamera'), findsOneWidget);
    });
  });
}
