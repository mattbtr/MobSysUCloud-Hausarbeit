import 'package:flutter/material.dart';
import '../../core/models/kunde.dart';
import '../../core/models/standort.dart';
import '../../core/models/abteilung.dart';
import '../../core/models/anlage.dart';
import '../../core/models/report.dart';
import '../../core/services/kunden_service.dart';
import '../../core/services/standort_service.dart';
import '../../core/services/abteilung_service.dart';
import '../../core/services/anlagen_service.dart';
import '../../core/services/report_service.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  // ignore: unused_field
  final _formKey = GlobalKey<FormState>();
  final _formKeyStep0 = GlobalKey<FormState>();
  final _formKeyStep1 = GlobalKey<FormState>();
  int _currentStep = 0;

  // Auswahlobjekte
  Kunde? selectedKunde;
  Standort? selectedStandort;
  Abteilung? selectedAbteilung;
  Anlage? selectedAnlage;

  // Listen aus der DB
  List<Kunde> kunden = [];
  List<Standort> standorte = [];
  List<Abteilung> abteilungen = [];
  List<Anlage> anlagen = [];

  // Formularfelder
  String titel = '';
  String beschreibung = '';
  DateTime selectedDate = DateTime.now();

  // Ladezustände prüfen
  bool isLoadingStandorte = false;
  bool isLoadingAbteilungen = false;
  bool isLoadingAnlagen = false;

  // Bericht Zustände
  // ignore: unused_field
  bool _isSubmitting = false;
  // ignore: unused_field
  bool _isReportSaved = false;
  // ignore: unused_field
  int? _reportId; // Speichert die ID des erstellten Reports

  @override
  void initState() {
    super.initState();
    _loadKunden();
  }

  Future<void> _loadKunden() async {
    kunden = await KundenService.fetchKunden();
    setState(() {});
  }

  Future<void> _loadStandorte(int kundenId) async {
    print("Lade Standorte für Kunde $kundenId...");
    setState((){
      isLoadingStandorte = true;
      standorte = [];
      selectedStandort = null;
      selectedAbteilung = null;
      selectedAnlage = null;
      abteilungen.clear();
      anlagen.clear();
    });
    final result = await StandortService.fetchStandorte(kundenId);
    print("Ergebnis: ${result.length} Standorte gefunden.");

    if (!mounted) return;
    
    setState(() {
      standorte = result;
      isLoadingStandorte = false;
    });
  }

  Future<void> _loadAbteilungen(int standortId) async {
    setState(() {
      isLoadingAbteilungen = true;
      abteilungen = [];
      selectedAbteilung = null;
      anlagen.clear();
      selectedAnlage = null;
    });
    final result = await AbteilungService.fetchAbteilungen(standortId);

    if (!mounted) return;

    setState(() {
      abteilungen = result;
      isLoadingAbteilungen = false;
    });
  }

  Future<void> _loadAnlagen(int abteilungId) async {
    setState(() {
      isLoadingAnlagen = true;
      anlagen = [];
      selectedAnlage = null;
    });
    final result = await AnlagenService.fetchAnlagen(abteilungId);

    if (!mounted) return;

    setState(() {
      anlagen = result;
      isLoadingAnlagen = false;
    });
  }

  Future<void> _submitReport() async {
    print('SubitReport aufgerufen');
    print(titel);
    print(beschreibung);
    print(selectedDate);
    print(selectedAnlage?.id);

    if (selectedAnlage == null || titel.isEmpty || beschreibung.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bitte alle Felder ausfüllen")),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);

    final report = Report(
      titel: titel,
      beschreibung: beschreibung,
      datum: selectedDate,
      anlageId: selectedAnlage!.id,
    );

    try {
      final result = await ReportService.submitReport(report);
      _reportId = result;
      setState(() {
        _isReportSaved = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Bericht gespeichert")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Fehler: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
    
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bericht erstellen")),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            if (_formKeyStep0.currentState!.validate()) {
              _formKeyStep0.currentState!.save();
              setState(() => _currentStep++);
            }
          } else if (_currentStep == 1) {
            if (_formKeyStep1.currentState!.validate()) {
              _formKeyStep1.currentState!.save();
              setState(() => _currentStep++);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Bitte alle Berichtfelder ausfüllen"),
                ),
              );
            }
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
            title: const Text("Stammdaten"),
            content: Form(
              key: _formKeyStep0,
              child: Column(
                children: [
                  DropdownButtonFormField<Kunde>(
                    decoration: const InputDecoration(labelText: "Kunde"),
                    items:
                        kunden
                            .map(
                              (k) => DropdownMenuItem(
                                value: k,
                                child: Text(k.name),
                              ),
                            )
                            .toList(),
                    value: selectedKunde,
                    onChanged: (val) {
                      setState(() => selectedKunde = val);
                      _loadStandorte(val!.id);
                    },
                    validator: (val) => val == null ? "Kunde wählen" : null,
                  ),
                  DropdownButtonFormField<Standort>(
                    decoration: const InputDecoration(labelText: "Standort"),
                    items:
                        standorte
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.name),
                              ),
                            )
                            .toList(),
                    value: selectedStandort,
                    onChanged:
                        isLoadingStandorte || standorte.isEmpty
                            ? null
                            : (val) {
                              setState(() => selectedStandort = val);
                              _loadAbteilungen(val!.id);
                            },
                    validator: (val) => val == null ? "Standort wählen" : null,
                  ),
                  DropdownButtonFormField<Abteilung>(
                    decoration: const InputDecoration(labelText: "Abteilung"),
                    items:
                        abteilungen
                            .map(
                              (a) => DropdownMenuItem(
                                value: a,
                                child: Text(a.name),
                              ),
                            )
                            .toList(),
                    value: selectedAbteilung,
                    onChanged:
                        isLoadingAbteilungen || abteilungen.isEmpty
                            ? null
                            : (val) {
                              setState(() => selectedAbteilung = val);
                              _loadAnlagen(val!.id);
                            },
                    validator: (val) => val == null ? "Abteilung wählen" : null,
                  ),
                  DropdownButtonFormField<Anlage>(
                    decoration: const InputDecoration(labelText: "Anlage"),
                    items:
                        anlagen
                            .map(
                              (a) => DropdownMenuItem(
                                value: a,
                                child: Text(a.name),
                              ),
                            )
                            .toList(),
                    value: selectedAnlage,
                    onChanged:
                        isLoadingAnlagen || anlagen.isEmpty
                            ? null
                            : (val) {
                              setState(() => selectedAnlage = val);
                            },
                    validator: (val) => val == null ? "Anlage wählen" : null,
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text("Bericht"),
            content: Form(
              key: _formKeyStep1,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Titel"),
                    onSaved: (val) => titel = val ?? '',
                    validator:
                        (val) =>
                            val == null || val.trim().isEmpty
                                ? "Titel erforderlich"
                                : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Beschreibung",
                    ),
                    maxLines: 3,
                    onSaved: (val) => beschreibung = val ?? '',
                    validator:
                        (val) =>
                            val == null || val.trim().isEmpty
                                ? "Beschreibung erforderlich"
                                : null,
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
          ),
          Step(
            title: const Text("Fertig"),
            content: const Text(
              "Überprüfe deine Eingaben und speichere den Bericht.",
            ),
          ),
        ],
      ),
    );
  }

}
