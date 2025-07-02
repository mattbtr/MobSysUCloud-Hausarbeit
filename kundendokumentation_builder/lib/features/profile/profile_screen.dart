import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Kein Benutzer angemeldet.');
    }
    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  void _changePassword(BuildContext context) {
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
              : FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: _fetchUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text('Benutzerdaten nicht gefunden.'),
                    );
                  }
                  final data = snapshot.data!.data()!;
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            child: Text(
                              (data['name'] != null && data['name'].isNotEmpty)
                                  ? data['name'][0].toUpperCase()
                                  : '?',
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            data['name'] ?? 'Unbekannter Name',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Center(
                          child: Text(
                            data['email'] ?? user.email ?? 'Unbekannte E-Mail',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Rolle: ${data['role'] ?? 'Unbekannt'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Abteilung: ${data['department'] ?? 'Unbekannt'}',
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
                  );
                },
              ),
    );
  }
}
