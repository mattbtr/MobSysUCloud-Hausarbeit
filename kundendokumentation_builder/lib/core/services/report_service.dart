import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/report.dart';

class ReportService {
  static Future<void> submitReport(Report report) async {
    final url = Uri.parse('http://192.168.0.108/berichte/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(report.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Fehler beim Speichern des Berichts: ${response.body}');
    }
  }
}
