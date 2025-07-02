import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/report.dart';
import '../models/eintrag.dart';
import '../models/stammdaten.dart';


class ReportService {
  static Future<int> submitReport(Report report) async {
    final url = Uri.parse('http://192.168.0.108:8000/berichte/');
    final payload = jsonEncode(report.toJson());
    print('➡️ POST $url');
    print('📦 Body: $payload');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(report.toJson()),
    );

    print('⬅️ Status: ${response.statusCode}');
    print('⬅️ Response: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Fehler beim Speichern des Berichts: ${response.body}');
    }
    // Annahme: Backend gibt {"id": 123} zurück
    final responseData = jsonDecode(response.body);
    return responseData['id'] as int;
  }


  static Future<List<Report>> fetchReports() async {
    final url = Uri.parse('http://192.168.0.108:8000/berichte/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) {
        // Achtung: Backend liefert "erstellt_am", nicht "datum"
        // Wir passen das Mapping an:
        return Report(
          id: json['id'], // <-- Hier die ID setzen!
          titel: json['titel'],
          beschreibung: json['beschreibung'],
          datum: DateTime.parse(json['erstellt_am']),
          anlageId: json['anlage_id'],
        );
      }).toList();
    } else {
      throw Exception('Fehler beim Laden der Berichte: ${response.body}');
    }
  }

  static Future<void> deleteReport(int reportId) async {
    final url = Uri.parse('http://192.168.0.108:8000/berichte/$reportId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Löschen des Berichts: ${response.body}');
    }
  }


  static Future<Report> fetchReport(int id) async {
    final url = Uri.parse('http://192.168.0.108:8000/berichte/$id/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return Report.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fehler beim Laden des Berichts: ${response.body}');
    }
  }

  static Future<List<Eintrag>> fetchEintraege(int berichtId) async {
    final url = Uri.parse('http://192.168.0.108:8000/berichte/$berichtId/eintraege');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Eintrag.fromJson(json)).toList();
    } else {
      throw Exception('Fehler beim Laden der Einträge: ${response.body}');
    }
  }

  static Future<Stammdaten> fetchStammdaten(int berichtId) async {
    final url = Uri.parse('http://192.168.0.108:8000/berichte/$berichtId/stammdaten');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return Stammdaten.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fehler beim Laden der Stammdaten: ${response.body}');
    }
  }


  // JSON-Upload
  static Future<bool> uploadJsonEntries(int reportId, File jsonFile) async {
    try {
      final uri = Uri.parse('http://192.168.0.108:8000/berichte/$reportId/eintraege/json');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            jsonFile.readAsBytesSync(),
            filename: jsonFile.path.split('/').last,
          ),
        );

      final response = await request.send();
       final responseBody = await response.stream.bytesToString();
      print('Upload JSON Response: ${response.statusCode} - $responseBody');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Bild-Upload
  static Future<bool> uploadImageEntry(
    int reportId,
    File imageFile,
    String titel,
    String beschreibung,
  ) async {
    try {
      final uri = Uri.parse('http://192.168.0.108:8000/berichte/$reportId/eintraege/image');
      final request =
          http.MultipartRequest('POST', uri)
            ..fields['titel'] = titel
            ..fields['beschreibung'] = beschreibung
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                imageFile.readAsBytesSync(),
                filename: imageFile.path.split('/').last,
              ),
            );

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

}
