import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  void _changePassword(BuildContext context) {
    // Hier könnte z. B. ein Dialog oder eigener Screen kommen
    showDialog(
      context: context,
      builder:
          (_) => const AlertDialog(
            title: Text("Passwort ändern"),
            content: Text("Diese Funktion wird demnächst implementiert."),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body:
          user == null
              ? const Center(child: Text('Kein Benutzer angemeldet.'))
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Optionales Avatar
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        child: Text(
                          user.email?.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        user.email ?? 'Unbekannte E-Mail',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Rolle: Techniker', // ⚠️ später dynamisch setzen
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Passwort ändern'),
                      onTap: () => _changePassword(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Abmelden'),
                      onTap: () => _signOut(context),
                    ),
                  ],
                ),
              ),
    );
  }
}
