import 'package:flutter/material.dart';
import 'package:kundendokumentation_builder/core/routes.dart';
import 'package:kundendokumentation_builder/features/report/visualization_screen.dart';
import '../../core/models/report.dart';
import '../../core/services/report_service.dart';

class ReportsOverviewScreen extends StatefulWidget {
  const ReportsOverviewScreen({super.key});

  @override
  State<ReportsOverviewScreen> createState() => _ReportsOverviewScreenState();
}

class _ReportsOverviewScreenState extends State<ReportsOverviewScreen> {
  String selectedFilter = 'Alle';
  final List<String> filterOptions = [
    'Alle',
    'Heute',
    'Diese Woche',
    'Favoriten',
  ];
  List<Report> reports = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => isLoading = true);
    try {
      reports = await ReportService.fetchReports();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler beim Laden: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<Report> getFilteredReports() {
    final now = DateTime.now();
    switch (selectedFilter) {
      case 'Heute':
        return reports
            .where(
              (report) =>
                  report.datum.year == now.year &&
                  report.datum.month == now.month &&
                  report.datum.day == now.day,
            )
            .toList();
      case 'Diese Woche':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return reports
            .where(
              (report) =>
                  report.datum.isAfter(startOfWeek) &&
                  report.datum.isBefore(now.add(const Duration(days: 1))),
            )
            .toList();
      case 'Favoriten':
        // TODO: Favoriten-Logik einbauen, falls du eine Favoriten-Funktion hast
        return reports;
      default:
        return reports;
    }
  }

  void _deleteReport(int index) async {
    // Hier müsstest du eigentlich die ID des Berichts übergeben,
    // aber dein Report-Model hat aktuell keine ID.
    // Wenn du eine ID brauchst, musst du das Model anpassen!
    // Beispiel für den Fall, dass du eine ID hast:
    // try {
    //   await ReportService.deleteReport(reports[index].id);
    //   setState(() => reports.removeAt(index));
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Fehler beim Löschen: $e')),
    //   );
    // }
    // Da dein Report-Model aktuell keine ID hat, kannst du nur lokal löschen:
    setState(() => reports.removeAt(index));
  }

  void _goToUpload() {
    Navigator.pushNamed(context, AppRoutes.upload);
  }

  void _goToReportDetail(Report report) {
    Navigator.pushNamed(
      context,
      AppRoutes.reportDetail,
      arguments: {
        'id': report.id, // <-- Hier muss die ID als int übergeben werden!
        'title': report.titel,
        'date': report.datum.toString(),
        // Optional: Weitere Daten übergeben
      },
    );
  }

  void _goToVisualization(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => VisualizationScreen(
              reportData: {
                'title': report.titel,
                'date': report.datum.toString(),
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = getFilteredReports();
    return Scaffold(
      appBar: AppBar(title: const Text('Berichte Übersicht')),
      body: Column(
        children: [
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Filter',
                border: OutlineInputBorder(),
              ),
              value: selectedFilter,
              items:
                  filterOptions.map((filter) {
                    return DropdownMenuItem(value: filter, child: Text(filter));
                  }).toList(),
              onChanged: (value) {
                setState(() => selectedFilter = value!);
              },
            ),
          ),
          // Liste aller Berichte
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredReports.isEmpty
                    ? const Center(child: Text('Keine Berichte gefunden'))
                    : ListView.builder(
                      itemCount: filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(report.titel),
                            subtitle: Text(
                              'Erstellt am: ${report.datum.toLocal().toString().split(' ')[0]}',
                            ),
                            onTap: () => _goToReportDetail(report),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'löschen':
                                    _deleteReport(index);
                                    break;
                                  case 'hinzufügen':
                                    _goToUpload();
                                    break;
                                  case 'visualisieren':
                                    _goToVisualization(report);
                                    break;
                                  case 'pdf':
                                    _goToReportDetail(report);
                                    break;
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'hinzufügen',
                                      child: Text('Daten hinzufügen'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'visualisieren',
                                      child: Text('Visualisieren'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'pdf',
                                      child: Text('PDF Export'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'löschen',
                                      child: Text('Löschen'),
                                    ),
                                  ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToUpload,
        child: const Icon(Icons.add),
      ),
    );
  }
}
