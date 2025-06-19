import 'package:flutter/material.dart';
// Optional für Diagramme
// import 'package:fl_chart/fl_chart.dart';

class VisualizationScreen extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const VisualizationScreen({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    // Beispielhafte strukturierte Daten
    final List<Map<String, dynamic>> components =
        reportData['components'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Bericht-Visualisierung')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            components.isEmpty
                ? const Center(
                  child: Text("Keine Daten zur Visualisierung verfügbar."),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Zustände der Komponenten",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: components.length,
                        itemBuilder: (context, index) {
                          final comp = components[index];
                          return Card(
                            child: ListTile(
                              title: Text(comp['name'] ?? 'Unbekannt'),
                              subtitle: Text("Status: ${comp['status']}"),
                              trailing: Icon(
                                Icons.circle,
                                color: _statusColor(comp['status']),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (reportData['note'] != null) ...[
                      const Text(
                        "Bemerkungen:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(reportData['note']),
                    ],
                  ],
                ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ok':
        return Colors.green;
      case 'warnung':
        return Colors.orange;
      case 'kritisch':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
