import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/services/report_service.dart';

class DataUploadScreen extends StatefulWidget {
  final int reportId;

  const DataUploadScreen({super.key, required this.reportId});

  @override
  State<DataUploadScreen> createState() => _DataUploadScreenState();
}

class _DataUploadScreenState extends State<DataUploadScreen> {
  bool _isUploading = false;

  Future<void> _uploadJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _isUploading = true);
      final file = File(result.files.single.path!);
      final success = await ReportService.uploadJsonEntries(
        widget.reportId,
        file,
      );
      setState(() => _isUploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Einträge gespeichert' : 'Fehler beim Hochladen',
          ),
        ),
      );
    }
  }

  Future<void> _uploadImageWithDetails() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.isNotEmpty) {
      final titelController = TextEditingController();
      final beschreibungController = TextEditingController();

      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Bildbeschreibung"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titelController,
                    decoration: const InputDecoration(labelText: "Titel"),
                  ),
                  TextField(
                    controller: beschreibungController,
                    decoration: const InputDecoration(
                      labelText: "Beschreibung",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Abbrechen"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isUploading = true);

                    final file = File(result.files.single.path!);
                    final success = await ReportService.uploadImageEntry(
                      widget.reportId,
                      file,
                      titelController.text,
                      beschreibungController.text,
                    );

                    setState(() => _isUploading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Bild gespeichert'
                              : 'Fehler beim Hochladen',
                        ),
                      ),
                    );
                  },
                  child: const Text("Hochladen"),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daten hinzufügen")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isUploading) const LinearProgressIndicator(),
            ElevatedButton.icon(
              icon: const Icon(Icons.file_upload),
              label: const Text("JSON-Datei hochladen"),
              onPressed: _uploadJsonFile,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text("Bild hinzufügen"),
              onPressed: _uploadImageWithDetails,
            ),
          ],
        ),
      ),
    );
  }
}
