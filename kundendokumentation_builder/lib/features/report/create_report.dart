import 'package:flutter/material.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  int _currentStep = 0;

  final _formKey = GlobalKey<FormState>();

  // Formulardaten
  String? selectedAnlage;
  String beschreibung = '';
  String status = 'OK';
  String messwerte = '';
  DateTime selectedDate = DateTime.now();

  // Dummy-Daten
  final List<String> anlagen = ['Anlage 1', 'Anlage 2', 'Anlage 3'];
  final List<String> statusOptions = ['OK', 'Mangel', 'Wartung nötig'];

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // TODO: API-Aufruf oder lokale Speicherung
      print('Bericht erstellt!');
      print('Anlage: $selectedAnlage');
      print('Status: $status');
      print('Beschreibung: $beschreibung');
      print('Messwerte: $messwerte');
      print('Datum: $selectedDate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bericht erstellen")),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else {
              _submitReport();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          steps: [
            Step(
              title: const Text("Anlage"),
              content: DropdownButtonFormField<String>(
                value: selectedAnlage,
                items:
                    anlagen
                        .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                        .toList(),
                onChanged: (val) => setState(() => selectedAnlage = val),
                validator: (val) => val == null ? "Bitte wählen" : null,
              ),
            ),
            Step(
              title: const Text("Details"),
              content: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Beschreibung",
                    ),
                    maxLines: 3,
                    onSaved: (val) => beschreibung = val ?? '',
                  ),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(labelText: "Status"),
                    items:
                        statusOptions
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => status = val ?? 'OK'),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      "Datum: ${selectedDate.toLocal()}".split(' ')[0],
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            Step(
              title: const Text("Messwerte"),
              content: TextFormField(
                decoration: const InputDecoration(labelText: "Messwerte"),
                maxLines: 4,
                onSaved: (val) => messwerte = val ?? '',
              ),
            ),
            Step(
              title: const Text("Bilder"),
              content: Column(
                children: [
                  const Text("TODO: Bild-Upload via image_picker"),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Bild aufnehmen oder Galerie
                    },
                    child: const Text("Bild hinzufügen"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
