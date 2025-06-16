import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final FirebaseAuth auth;

  RegisterScreen({super.key, FirebaseAuth? auth})
    : auth = auth ?? FirebaseAuth.instance;

  // Registrierungs-Logik (Funktion)
  void register(BuildContext context) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!context.mounted) return; // schützt vor ungültigem Kontext

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'E-Mail is already in use.';
          break;
        case 'invalid-email':
          message = 'E-Mail is not valid.';
          break;
        case 'weak-password':
          message = 'password is too weak.';
          break;
        default:
          message = 'Registration failed';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unknown exception: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-Mail'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Passowrd'),
            ),

            const SizedBox(height: 16),

            // Register-Button: Bei Drücken wird Register-Funktion von oben ausgeführt
            ElevatedButton(
              onPressed: () => register(context),
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
