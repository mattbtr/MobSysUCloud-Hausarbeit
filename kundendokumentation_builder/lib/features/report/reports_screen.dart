import 'package:flutter/material.dart';
import 'package:kundendokumentation_builder/core/routes.dart';
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
    final report = getFilteredReports()[index];
    final reportId = report.id;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Bericht löschen?'),
            content: const Text('Möchtest du diesen Bericht wirklich löschen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Löschen'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await ReportService.deleteReport(reportId!);
      setState(() {
        reports.removeWhere((r) => r.id == reportId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bericht gelöscht!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler beim Löschen: $e')));
    }
  }


  void _goToUpload(Report report) {
    Navigator.pushNamed(
      context,
      AppRoutes.upload,
      arguments: {'reportId': report.id},
    );
  }


  void _goToCreateReport() {
    Navigator.pushNamed(context, AppRoutes.createReport);
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final bool forUpload = args is Map && args['forUpload'] == true;

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

          if (forUpload)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Bitte wähle einen Bericht für den Datenupload aus.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
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
                            onTap: () {
                              if (forUpload) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.upload,
                                  arguments: {'reportId': report.id},
                                );
                              } else {
                                _goToReportDetail(report);
                              }
                            },
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'löschen':
                                    _deleteReport(index);
                                    break;
                                  case 'hinzufügen':
                                    _goToUpload(report);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCreateReport,
        label: const Text('Neuer Bericht'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
