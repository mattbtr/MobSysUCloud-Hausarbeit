import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart'; // Import der RegisterPage, damit mit Button auf diese weitergeleitet werden kann

class LoginScreen extends StatelessWidget {
  // Firbase Auth Objekt
  final FirebaseAuth auth;

  // Controller für die Texteingabe in den E-Mail- und Passwortfeldern
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginScreen({
    super.key,
    FirebaseAuth? auth,
  }) //optionaler Parameter --> FirebaseAuth?
  : auth =
           auth ??
           FirebaseAuth
               .instance; // Wert übergeben wurde (z. B. ein MockFirebaseAuth), dann wird dieser verwendet

  // Login-Funktion
  void login(BuildContext context) async {
    try {
      await auth.signInWithEmailAndPassword(
        // Authentication simpel mit Email und Passwort (gibt auch andere Auth-Methode, die man aktivieren kann in Firebase !!)
        email:
            emailController.text
                .trim(), // holt Text aus dem Textfeld für Email (vgl Zeile 38)
        password:
            passwordController.text
                .trim(), // .trim() entfernt Leerzeichen vorne und hinten ams String
      );
    } catch (e) {
      if (!context.mounted) {
        return; // schützt vor ungültigem Kontext --> Sicherstellen, dass das Widget noch im Widget-Baum vorhanden ist.
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      ); // Snackbar Fehlermeldung, wenn email und Passwort nicht mit Usern in DB übereinstimmen
    }
  } // Ende Login-Funktion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')), // AppBar mit Titel: Login
      body: Padding(
        padding: const EdgeInsets.all(
          16,
        ), // Abstand von gesamten Inhalt innerhalb von body bzw Scaffold nach außen zu body bzw scaffold
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-Mail'),
            ), // Textfeld für Email Eingabe
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ), // obscureTExt: Versteckt Passwortzeichen beim Tippen

            const SizedBox(
              height: 16,
            ), // SizedBox == unsichtbares Abstandswidget --> Abstand von 16 Pixel zwischen Textfeld-PW und Button-Login
            // Button-Login führt Login-Funktion von oben aus
            ElevatedButton(
              onPressed: () => login(context),
              child: const Text('Login'),
            ),
            // TextButton (Link zu Register-Page) --> hier wird RegisterScreen-Klasse geladen
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                  ),
              child: const Text('Noch kein Konto? Jetzt registrieren.'),
            ),
          ],
        ),
      ),
    );
  }
}
