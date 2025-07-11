import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

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

  static Future<void> exportAndSendEmail(
    int reportId, {
    required BuildContext context,
    Function(String)? onError,
  }) async {
    // 1. Empfänger-Adresse abfragen
    final emailController = TextEditingController();
    final recipient = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Empfänger-E-Mail eingeben'),
            content: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'z.B. max@kunde.de'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, emailController.text),
                child: const Text('Senden'),
              ),
            ],
          ),
    );

    if (recipient == null || recipient.isEmpty) {
      if (context.mounted) {
        onError?.call('E-Mail-Versand abgebrochen.');
      }
      return;
    }

    // 2. Request an Backend senden
    final url = 'http://192.168.0.108:8000/berichte/$reportId/export/email';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'recipient': recipient}),
      );
      if (response.statusCode == 200) {
         if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('E-Mail wurde versendet!')),
          );
        }
      } else {
        if (context.mounted) {
          onError?.call('Fehler beim E-Mail-Export: ${response.body}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        onError?.call('Fehler beim E-Mail-Export: $e');
      }
    }
  }
}
