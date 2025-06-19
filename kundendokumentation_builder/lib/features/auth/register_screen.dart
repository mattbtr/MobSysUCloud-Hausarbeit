import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// stateful wegen DropDown-Boxen --> ändern widget
class RegisterScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  RegisterScreen({super.key, FirebaseAuth? auth, FirebaseFirestore? firestore})
    : auth = auth ?? FirebaseAuth.instance,
      firestore = firestore ?? FirebaseFirestore.instance;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  String? selectedRole;
  String? selectedDepartment;

  final List<String> roles = ['Admin', 'Techniker', 'Gast'];
  final List<String> departments = ['Produktion', 'Qualitätssicherung', 'Instandhaltung'];

  void register(BuildContext context) async {
    // prüfung rolle und abteilung felder ausgefüllt
    if (selectedRole == null || selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Rolle und Abteilung auswählen')),
      );
      return;
    }
    // prüfung namens feld ausgefüllt
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gib deinen Vor- und Nachnamen ein')),
      );
      return;
    }

    try {
      // firebase_auth --> auf authentifizierung warten mit email u. pw
      final userCredential = await widget.auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      // wenn authentifzierung erfolgreich war --> dh. user != null
      if (user != null) {
        await widget.firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': nameController.text.trim(),
          'role': selectedRole,
          'department': selectedDepartment,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!context.mounted) return; // schützt vor ungültigem Kontext

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}'); // ← DAS HINZUFÜGEN!
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'E-Mail ist bereits registriert.';
          break;
        case 'invalid-email':
          message = 'Ungültige E-Mail-Adresse.';
          break;
        case 'weak-password':
          message = 'Passwort ist zu schwach.';
          break;
        default:
          message = 'Registrierung fehlgeschlagen.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unbekannter Fehler: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrieren')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-Mail'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Passwort'),
              obscureText: true,
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Vor- und Nachname'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Rolle'),
              value: selectedRole,
              items:
                  roles
                      .map(
                        (role) =>
                            DropdownMenuItem(value: role, child: Text(role)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => selectedRole = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Abteilung'),
              value: selectedDepartment,
              items:
                  departments
                      .map(
                        (dep) => DropdownMenuItem(value: dep, child: Text(dep)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => selectedDepartment = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => register(context),
              child: const Text("Registrieren"),
            ),
          ],
        ),
      ),
    );
  }
}
