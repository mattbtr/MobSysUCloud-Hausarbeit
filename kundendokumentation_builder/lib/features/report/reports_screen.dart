import 'package:flutter/material.dart';
import 'package:kundendokumentation_builder/core/routes.dart';
import 'package:kundendokumentation_builder/features/report/visualization_screen.dart';

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

  // Dummy-Daten für Berichte (später durch echte aus DB ersetzen)
  final List<Map<String, String>> reports = [
    {'title': 'Bericht 1', 'date': '2025-06-15'},
    {'title': 'Bericht 2', 'date': '2025-06-12'},
    {'title': 'Bericht 3', 'date': '2025-06-10'},
  ];

  void _deleteReport(int index) {
    setState(() {
      reports.removeAt(index);
    });
  }

  void _goToUpload() {
    Navigator.pushNamed(context, AppRoutes.upload);
  }

  void _goToReportDetail(Map<String, String> report) {
    // Daten an Detail-View übergeben - Beispiel-daten
    Navigator.pushNamed(
      context,
      AppRoutes.reportDetail,
      arguments: {
        'title': report['title'],
        'date': report['date'],
        'customer': 'Firma XYZ',
        'location': 'München',
        'department': 'Technik',
        'system': 'Filteranlage A',
        'entries': [
          {'title': 'Temperatur', 'note': '25°C', 'hasImage': false},
          {'title': 'Leckageprüfung', 'note': 'OK', 'hasImage': true},
        ],
      },
    );
  }

  void _goToVisualization(Map<String, String> report) {
    Navigator.push(context,
    MaterialPageRoute(
        builder: (_) => VisualizationScreen(reportData: report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                setState(() {
                  selectedFilter = value!;
                  // TODO: Filter-Logik einbauen
                });
              },
            ),
          ),

          // Liste aller Berichte
          Expanded(
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(report['title'] ?? ''),
                    subtitle: Text('Erstellt am: ${report['date']}'),
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
                            _goToReportDetail(report); // Export erfolgt dort
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
