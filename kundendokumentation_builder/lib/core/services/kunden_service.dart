// lib/core/services/kunden_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/kunde.dart';

class KundenService {
  static Future<List<Kunde>> fetchKunden() async  {
    final url = Uri.parse('http://192.168.0.108:8000/kunden/');
    final response = await http.get(url);

    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Kunde.fromJson(json)).toList();
    } else{
      throw Exception('Fehler beim Laden der Kunden: ${response.body}');
    }
  }
}

