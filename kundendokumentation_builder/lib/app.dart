import 'package:flutter/material.dart';
import 'package:kundendokumentation_builder/features/auth/auth_logic.dart'; // (zeigt Login oder HomeScrenn je Auth.status)
import 'core/routes.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kundendokumentation Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: AuthLogic(), // Start-Widget abhängig vom Login-Status
      routes: AppRoutes.routes,
    );
  }
}
