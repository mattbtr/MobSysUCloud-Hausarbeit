import 'package:flutter/material.dart';
import 'dart:io';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  List<File> uploadedImages = [];
  String structuredData = '';

  void _addStructuredData() {
    // Öffnet einen Dialog oder navigiert weiter zu einem Dateneingabeformular
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Strukturierte Daten eingeben'),
            content: TextField(
              onChanged: (value) => structuredData = value,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'z.B. Standort: München, Anlage: XYZ',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {}); // aktualisiert UI
                },
                child: const Text('Speichern'),
              ),
            ],
          ),
    );
  }

  void _uploadImageFromGallery() {
    // TODO: Implementiere Image Picker für Galerie
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🖼️ Galerie-Funktion noch nicht implementiert'),
      ),
    );
  }

  void _captureImageWithCamera() {
    // TODO: Implementiere Kameraaufnahme
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 Kamera-Funktion noch nicht implementiert'),
      ),
    );
  }

  void _saveUpload() {
    // TODO: Hochgeladene Daten speichern (z. B. in Firestore oder API)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ Upload gespeichert')));
  }

  void _discardUpload() {
    setState(() {
      uploadedImages.clear();
      structuredData = '';
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('🗑️ Upload verworfen')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datenupload')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload-Optionen:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _addStructuredData,
              icon: const Icon(Icons.edit_note),
              label: const Text('Strukturierte Daten hinzufügen'),
            ),
            ElevatedButton.icon(
              onPressed: _uploadImageFromGallery,
              icon: const Icon(Icons.upload_file),
              label: const Text('Bild aus Galerie hochladen'),
            ),
            ElevatedButton.icon(
              onPressed: _captureImageWithCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Foto aufnehmen'),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const Text(
              'Vorschau:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (structuredData.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.blue[50],
                child: Text(structuredData),
              ),

            if (uploadedImages.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    uploadedImages
                        .map(
                          (img) => Image.file(
                            img,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                        .toList(),
              ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveUpload,
                  icon: const Icon(Icons.save),
                  label: const Text('Speichern'),
                ),
                OutlinedButton.icon(
                  onPressed: _discardUpload,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Verwerfen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
