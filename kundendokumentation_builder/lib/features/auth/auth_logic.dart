import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Zugriff auf Firebase Authentication (Login, Logout, Registry)
import '../home/home_screen.dart'; // importiert HomeScreen der angezeigt wird wenn angemeldet
import 'login_screen.dart'; // importiert LoginScreen, der standardweise angezeigt wird wenn nicht angemeldet

class AuthLogic extends StatelessWidget {
  const AuthLogic({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return StreamBuilder<User?>(
      // Dieser Stream liefert `User?`: entweder ein eingeloggter Benutzer oder `null`, wenn ausgeloggt -->EReknnt automatisch Änderung: Baut das Widget neu auf, sobald sich der Stream ändert (also Benutzer sich anmeldet oder Benutzer sich abmeldet).
      stream:
          FirebaseAuth.instance
              .authStateChanges(), // Lauscht auf Änderungen des Authentifizierungsstatus.
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Während der Verbindungsaufbau zu Firebase läuft, wird ein Ladeindikator angezeigt
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // Wenn ein Benutzer vorhanden ist (also angemeldet), zeige die Hauptseite.
          return HomeScreen();
        } else {
          // Ansonsten: zeige den Login-Bildschirm (inkl. Button zur Registrierung)
          return LoginScreen();
        }
      },
    );
  }
}
