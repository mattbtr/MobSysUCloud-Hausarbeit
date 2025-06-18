import 'package:flutter/material.dart';
import 'package:kundendokumentation_builder/widgets/export_dialog.dart';

class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailScreen({super.key, required this.report});

  void _showExportOptions(
    BuildContext context,
    Map<String, dynamic> reportData,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ExportDialog(reportData: reportData),
    );
  }

  void _editReport(BuildContext context) {
    // TODO: Navigation zum Bearbeitungsbildschirm
    Navigator.pushNamed(context, '/edit_report');
  }

  @override
  Widget build(BuildContext context) {
    // Beispielhafte Strukturdaten (Placeholder für spätere dynamische Inhalte)
    final reportTitle = report['title'] ?? 'Bericht ohne Titel';
    final customer = report['customer'] ?? 'Musterkunde';
    final location = report['location'] ?? 'Standort A';
    final department = report['department'] ?? 'Abteilung B';
    final system = report['system'] ?? 'Anlage C';
    final timestamp = report['date'] ?? '2025-06-16';

    final entries = report['entries'] as List<Map<String, dynamic>>? ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(reportTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kunde: $customer',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('Standort: $location'),
            Text('Abteilung: $department'),
            Text('Anlage: $system'),
            const SizedBox(height: 8),
            Text(
              'Erstellt am: $timestamp',
              style: const TextStyle(color: Colors.grey),
            ),

            const Divider(height: 24),

            Text('Einträge', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),

            Expanded(
              child:
                  entries.isNotEmpty
                      ? ListView.separated(
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return ListTile(
                            title: Text(entry['title'] ?? 'Eintrag $index'),
                            subtitle: Text(entry['note'] ?? ''),
                            trailing:
                                entry['hasImage'] == true
                                    ? const Icon(
                                      Icons.image,
                                      color: Colors.blue,
                                    )
                                    : null,
                          );
                        },
                      )
                      : const Text('Keine Einträge vorhanden.'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Zurück'),
            ),
            ElevatedButton.icon(
              onPressed: () => _editReport(context),
              icon: const Icon(Icons.edit),
              label: const Text('Bearbeiten'),
            ),
            ElevatedButton.icon(
              onPressed: () => _showExportOptions(context, report),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }
}
