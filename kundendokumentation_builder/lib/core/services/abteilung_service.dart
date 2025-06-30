// lib/core/services/abteilung_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/abteilung.dart';

class AbteilungService {
  static Future<List<Abteilung>> fetchAbteilungen(int standortId) async {
    final url = Uri.parse('http://192.168.0.108:8000/abteilungen/standort/$standortId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Abteilung.fromJson(json)).toList();
    } else {
      throw Exception('Fehler beim Laden der Abteilungen: ${response.body}');
    }
  }
}
