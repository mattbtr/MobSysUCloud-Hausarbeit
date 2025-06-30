// lib/core/services/anlagen_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/anlage.dart';

class AnlagenService {
  static Future<List<Anlage>> fetchAnlagen(int abteilungId) async {
    final url = Uri.parse('http://192.168.0.108:8000/anlagen/abteilung/$abteilungId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Anlage.fromJson(json)).toList();
    } else {
      throw Exception('Fehler beim Laden der Anlagen: ${response.body}');
    }
  }
}
