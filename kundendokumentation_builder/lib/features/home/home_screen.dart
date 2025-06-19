import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final logger = Logger();

  void _navigateTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  void logout() {
    HomeScreen.logger.i(
      "Aktuelle UID: ${FirebaseAuth.instance.currentUser?.uid}",
    );
    FirebaseAuth.instance.signOut();
  }

  void _openCamera(BuildContext context) {
    //  Kamera-Funktion implementieren
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _HomeButton(
              icon: Icons.cloud_upload,
              label: 'Datenupload',
              onTap: () => _navigateTo(context, '/upload'),
            ),
            const SizedBox(height: 15),
            _HomeButton(
              icon: Icons.description,
              label: 'Berichte Übersicht',
              onTap: () => _navigateTo(context, '/reports'),
            ),
            const SizedBox(height: 15),
            _HomeButton(
              icon: Icons.search,
              label: 'Spezifischen Bericht suchen',
              onTap: () => _navigateTo(context, '/search-report'),
            ),
            const SizedBox(height: 15),
            _HomeButton(
              icon: Icons.person,
              label: 'Profil',
              onTap: () => _navigateTo(context, '/profile'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCamera(context),
        tooltip: 'Kamera öffnen',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeButton({
    // ignore: unused_element_parameter
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
        ),
        onPressed: onTap,
      ),
    );
  }
}

