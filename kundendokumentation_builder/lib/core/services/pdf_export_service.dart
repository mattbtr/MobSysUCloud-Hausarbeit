import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfExportService {
  /// Lädt das PDF für den gegebenen Report vom Backend und öffnet es.
  static Future<void> exportAsPDF(
    int reportId, {
    Function(String)? onError,
  }) async {
    final url =
        'http://192.168.0.108:8000/berichte/$reportId/export/pdf'; // ggf. anpassen
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/bericht_$reportId.pdf');
        await file.writeAsBytes(response.bodyBytes);
        await OpenFile.open(file.path);
      } else {
        onError?.call('Fehler beim PDF-Export: ${response.statusCode}');
      }
    } catch (e) {
      onError?.call('Fehler beim PDF-Export: $e');
    }
  }

  /// Optional: Dummy für E-Mail-Funktion (noch nicht implementiert)
  static Future<void> exportAndSendEmail(
    int reportId, {
    Function(String)? onError,
  }) async {
    // Hier könntest du später einen Mailversand implementieren
    onError?.call('E-Mail-Versand ist noch nicht implementiert.');
  }
}
