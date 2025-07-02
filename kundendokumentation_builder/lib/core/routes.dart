// // zentrale Route-Konfiguration
import 'package:flutter/material.dart';
import 'package:kundendokumentation_builder/features/home/home_screen.dart';
import 'package:kundendokumentation_builder/features/report/create_report.dart';
import 'package:kundendokumentation_builder/features/report/reports_screen.dart';
import 'package:kundendokumentation_builder/features/report/report_detail_screen.dart';
import 'package:kundendokumentation_builder/features/profile/profile_screen.dart';
import 'package:kundendokumentation_builder/features/report/data_upload.dart';

class AppRoutes {
  static const home = '/home';
  static const upload = '/upload';
  static const reports = '/reports';
  static const reportDetail = '/report_detail';
  static const profile = '/profile';
  static const createReport = '/create_report';
  // usw.

  static Map<String, WidgetBuilder> routes = {
    home: (_) => const HomeScreen(),
    reports: (_) => const ReportsOverviewScreen(),
    profile: (_) => const ProfileScreen(),
    createReport: (_) => const CreateReportScreen(),
    
    
    reportDetail: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      print('Argumente: $args'); // <-- Debug-Ausgabe
      if (args is Map<String, dynamic> && args['id'] != null) {
        return ReportDetailScreen(reportId: args['id'] as int);
      }
      return const Scaffold(body: Center(child: Text("Ungültiger Bericht")));
    },

    upload: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args['reportId'] != null) {
        return DataUploadScreen(reportId: args['reportId'] as int);
      }
      return const Scaffold(body: Center(child: Text("Ungültiger Bericht")));
    },

    
    // usw.
  };
}
