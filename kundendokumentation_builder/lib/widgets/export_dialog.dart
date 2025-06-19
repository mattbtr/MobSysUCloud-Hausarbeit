import 'package:flutter/material.dart';
import 'package:kundendokumentation_builder/core/services/export_service.dart';

class ExportDialog extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const ExportDialog({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Als PDF exportieren'),
            onTap: () async {
              Navigator.pop(context);
              await ExportService.exportAsPDF(reportData);
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Als PDF exportieren & per E-Mail senden'),
            onTap: () async {
              Navigator.pop(context);
              await ExportService.exportAndSendEmail(reportData);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text('Abbrechen'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
