import 'package:flutter/material.dart'; // import für Design UI-Toolkit von Flutter (Widgets, Themes etc.)
import 'package:firebase_core/firebase_core.dart'; // Firebase Core Package für Firebase App in Flutter
//import 'firebase_options.dart';   // enthält Firebase-Prohjekt-Konfiguration
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options_env.dart'; // ersetzt firebase_options.dart
import 'package:logger/logger.dart';
import 'app.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Sorgt dafür, dass alle Widgets und Dienste bevor Firebase initialisiert wird.

  await dotenv.load(fileName: '.env');

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        // Firebase Projekt initialisieren
        options: FirebaseOptionsEnv.currentPlatform,
        // Verwendet die manuelle Konfiguration aus firebase_options_env.dart die die Werte aus .env nimmt
        // (enthält u. a. API-Key, Projekt-ID etc.)
      );
    }
    // ignore: avoid_print
    print("Anzahl Firebase-Apps: ${Firebase.apps.length}");
    for (var app in Firebase.apps) {
      // ignore: avoid_print
      print("Gefundene App: ${app.name}");
    }
  } catch (e) {
    //print('Firebase init error: $e');
    logger.e('Firebase init error: $e');
  }

  runApp(const MainApp());
}


