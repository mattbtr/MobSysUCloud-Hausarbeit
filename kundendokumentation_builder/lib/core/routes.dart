// // zentrale Route-Konfiguration
import 'package:flutter/material.dart';
import 'package:kundendokumentation_builder/features/home/home_screen.dart';
import 'package:kundendokumentation_builder/features/upload/upload_screen.dart';
import 'package:kundendokumentation_builder/features/report/reports_screen.dart';
import 'package:kundendokumentation_builder/features/report/report_detail_screen.dart';
import 'package:kundendokumentation_builder/features/profile/profile_screen.dart';

class AppRoutes {
  static const home = '/home';
  static const upload = '/upload';
  static const reports = '/reports';
  static const reportDetail = '/report_detail';
  static const profile = '/profile';
  // usw.

  static Map<String, WidgetBuilder> routes = {
    home: (_) => const HomeScreen(),
    upload: (_) => const UploadScreen(),
    reports: (_) => const ReportsOverviewScreen(),
    profile: (_) => const ProfileScreen(),
    
    reportDetail: (context){
      final args = ModalRoute.of(context)?.settings.arguments;
      if(args is Map<String, dynamic>){
        return ReportDetailScreen(report: args);
      }
      return const Scaffold(body: Center(child: Text("Ungültiger Bericht"),),);
    },
    
    // usw.
  };
}
