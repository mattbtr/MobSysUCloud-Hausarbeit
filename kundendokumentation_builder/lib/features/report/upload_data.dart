import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class UploadDataScreen extends StatefulWidget {
  final int reportId;

  const UploadDataScreen({super.key, required this.reportId});

  @override
  State<UploadDataScreen> createState() => _UploadDataScreenState();
}

class _UploadDataScreenState extends State<UploadDataScreen> {
  List<Map<String, dynamic>> jsonEntries = [];
  final ImagePicker _imagePicker = ImagePicker();
  List<Map<String, dynamic>> selectedImages = [];

  Future<void> _pickJsonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final contents = await file.readAsString();

      try {
        final decoded = json.decode(contents);

        if (decoded is List && decoded.length <= 3) {
          setState(() {
            jsonEntries = decoded.cast<Map<String, dynamic>>();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("JSON erfolgreich geladen")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Maximal 3 Einträge erlaubt")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Fehler beim Parsen: $e")));
      }
    }
  }

  Future<void> _pickImages() async {
    if (selectedImages.length >= 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Maximal 3 Bilder erlaubt")));
      return;
    }

    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final titleController = TextEditingController();
      final descController = TextEditingController();

      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Bildinfos eingeben"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Titel"),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Beschreibung"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Abbrechen"),
              ),
              TextButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    setState(() {
                      selectedImages.add({
                        "path": pickedFile.path,
                        "title": titleController.text,
                        "description": descController.text,
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bild hinzugefügt")),
                    );
                  }
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daten hochladen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Report-ID: ${widget.reportId}'),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text("JSON-Datei hochladen"),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text("JSON-Datei auswählen"),
                      onPressed: _pickJsonFile,
                    ),
                    const SizedBox(height: 8),
                    const Text("0–3 strukturierte Einträge"),
                    if (jsonEntries.isNotEmpty)
                      Text("${jsonEntries.length} Einträge geladen"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text("Bilder hochladen"),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text("Bild auswählen"),
                      onPressed: _pickImages,
                    ),
                    const SizedBox(height: 8),
                    const Text("Max. 3 Bilder mit Titel & Beschreibung"),
                    if (selectedImages.isNotEmpty)
                      Text("${selectedImages.length} Bilder ausgewählt"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Hier könntest du die Daten an das Backend schicken
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Daten werden gesendet...")),
                );
                // Beispiel: ReportService.uploadData(widget.reportId, jsonEntries, selectedImages);
              },
              child: const Text("Daten abschicken"),
            ),
          ],
        ),
      ),
    );
  }
}
