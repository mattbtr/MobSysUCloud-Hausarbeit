import 'package:flutter/material.dart';
import 'package:kundendokumentation_builder/core/routes.dart';
import 'package:kundendokumentation_builder/widgets/export_dialog.dart';
import '../../core/models/report.dart';
import '../../core/models/eintrag.dart';
import '../../core/models/stammdaten.dart';
import '../../core/services/report_service.dart';

class ReportDetailScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  Report? report;
  List<Eintrag> eintraege = [];
  Stammdaten? stammdaten;
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = '';
    });
    try {
      report = await ReportService.fetchReport(widget.reportId);
      eintraege = await ReportService.fetchEintraege(widget.reportId);
      stammdaten = await ReportService.fetchStammdaten(widget.reportId);
    } catch (e) {
      setState(() => error = 'Fehler beim Laden: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showExportOptions(BuildContext context) {
    if (report == null || report!.id == null) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => ExportDialog(reportId: report!.id!),
    );
  }

  void _editReport(BuildContext context, int reportId) {
    Navigator.pushNamed(
      context,
      AppRoutes.upload,
      arguments: {'reportId': reportId},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fehler')),
        body: Center(child: Text(error)),
      );
    }
    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bericht nicht gefunden')),
        body: const Center(child: Text('Bericht nicht gefunden')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(report!.titel)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kunde: ${stammdaten?.kunde['name'] ?? 'Unbekannt'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Standort: ${stammdaten?.standort['name'] ?? 'Unbekannt'}'),
            Text('Abteilung: ${stammdaten?.abteilung['name'] ?? 'Unbekannt'}'),
            Text('Anlage: ${stammdaten?.anlage['name'] ?? 'Unbekannt'}'),
            const SizedBox(height: 8),
            Text(
              'Erstellt am: ${report!.datum.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 24),
            const Text(
              'Einträge',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  eintraege.isNotEmpty
                      ? ListView.separated(
                        itemCount: eintraege.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final entry = eintraege[index];
                          final isImage =
                              entry.wert != null &&
                              (entry.wert!.startsWith('/uploads/') ||
                                  entry.wert!.contains('.jpg') ||
                                  entry.wert!.contains('.png') ||
                                  entry.wert!.contains('.jpeg'));

                          return ListTile(
                            title: Text(entry.titel),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (entry.beschreibung != null &&
                                    entry.beschreibung!.isNotEmpty)
                                  Text(entry.beschreibung!),
                                if (isImage)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Image.network(
                                      'http://192.168.0.108:8000${entry.wert}',
                                      width: 200,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => const Text(
                                            'Bild konnte nicht geladen werden',
                                          ),
                                    ),
                                  ),
                                if (!isImage &&
                                    entry.wert != null &&
                                    entry.wert!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('Wert: ${entry.wert}'),
                                  ),
                              ],
                            ),
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
              onPressed: () {
                if (report!.id != null) {
                  _editReport(context, report!.id!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bericht hat keine ID!')),
                  );
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Bearbeiten'),
            ),
            ElevatedButton.icon(
              onPressed: () => _showExportOptions(context),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }
}
