import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:kundendokumentation_builder/widgets/animated_button.dart';
import 'package:kundendokumentation_builder/features/home/camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static final logger = Logger();
  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _username = "Nutzer");
      return;
    }
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    setState(() {
      _username = doc.data()?['name'] ?? user.email ?? "Nutzer";
    });
  }

  void _navigateTo(BuildContext context, String route, {bool forUpload = false}) {
    Navigator.pushNamed(context, route, arguments: forUpload ? {'forUpload': true} : null);
  }

  void logout(BuildContext context) {
    _HomeScreenState.logger.i(
      "Aktuelle UID: ${FirebaseAuth.instance.currentUser?.uid}",
    );
    FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _openCamera(BuildContext context) {
    Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hallo, ${_username ?? "Nutzer"}!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  AnimatedHomeButton(
                    icon: Icons.description,
                    label: 'Berichte Übersicht',
                    onTap: () => _navigateTo(context, '/reports'),
                  ),
                  const SizedBox(height: 18),
                  AnimatedHomeButton(
                    icon: Icons.create,
                    label: 'Bericht erstellen',
                    onTap: () => _navigateTo(context, '/create_report'),
                  ),
                  const SizedBox(height: 18),
                  AnimatedHomeButton(
                    icon: Icons.cloud_upload,
                    label: 'Datenupload',
                    onTap: () => _navigateTo(context, '/reports', forUpload: true),
                  ),
                  const SizedBox(height: 18),
                  AnimatedHomeButton(
                    icon: Icons.person,
                    label: 'Profil',
                    onTap: () => _navigateTo(context, '/profile'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCamera(context),
        label: const Text('Kamera'),
        icon: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
