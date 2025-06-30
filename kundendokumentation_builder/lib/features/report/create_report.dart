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
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
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
  String messwerte = '';
  DateTime selectedDate = DateTime.now();

  // Ladezustände prüfen
  bool isLoadingStandorte = false;
  bool isLoadingAbteilungen = false;
  bool isLoadingAnlagen = false;

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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final report = Report(
        titel: titel,
        beschreibung: beschreibung,
        datum: selectedDate,
        messwerte: messwerte,
        status: "OK", // Optional
        bilder: [],
        anlageId: selectedAnlage!.id,
      );

      try {
        await ReportService.submitReport(report);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Bericht gespeichert")));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Fehler: $e")));
      }
    }
  }

  List<Map<String, dynamic>> jsonEntries = []; // NEU

  Future<void> _pickJsonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final contents = await file.readAsString();

      try {
        final decoded = json.decode(contents);

        if (decoded is List && decoded.length <= 3) {
          jsonEntries = decoded.cast<Map<String, dynamic>>();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("JSON erfolgreich geladen")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Maximal 3 Einträge erlaubt")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Fehler beim Parsen: $e")));
      }
    }
  }

  final ImagePicker _imagePicker = ImagePicker();
  List<Map<String, dynamic>> selectedImages = []; // NEU

  Future<void> _pickImages() async {
    if (selectedImages.length >= 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Maximal 3 Bilder erlaubt")));
      return;
    }

    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final titleController = TextEditingController();
      final descController = TextEditingController();

      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Bildinfos eingeben"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Titel"),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Beschreibung"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // abbrechen
                },
                child: const Text("Abbrechen"),
              ),
              TextButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    selectedImages.add({
                      "path": pickedFile.path,
                      "title": titleController.text,
                      "description": descController.text,
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bild hinzugefügt")),
                    );
                  }
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
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
            if (_currentStep < 2) {
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
              title: const Text("Stammdaten"),
              content: Column(
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
                    onChanged: isLoadingStandorte || standorte.isEmpty ? null : (val) {
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
                    onChanged: isLoadingAbteilungen || abteilungen.isEmpty ? null : (val) {
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
                    onChanged: isLoadingAnlagen || anlagen.isEmpty ? null : (val) => setState(() => selectedAnlage = val),
                    validator: (val) => val == null ? "Anlage wählen" : null,
                  ),
                ],
              ),
            ),
            Step(
              title: const Text("Bericht-Keynotes"),
              content: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Titel"),
                    onSaved: (val) => titel = val ?? '',
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? "Titel erforderlich"
                                : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Beschreibung",
                    ),
                    maxLines: 3,
                    onSaved: (val) => beschreibung = val ?? '',
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
              title: const Text("Einträge (JSON)"), // NEU
              content: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text("JSON-Datei hochladen"),
                    onPressed: _pickJsonFile, // NEU
                  ),
                  Text("0–3 strukturierte Einträge"), // NEU
                ],
              ),
            ),
            Step(
              title: const Text("Bilder"), // NEU
              content: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text("Bild auswählen"),
                    onPressed: _pickImages, // NEU
                  ),
                  Text("Max. 3 Bilder mit Titel & Beschreibung"), // NEU
                ],
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
      ),
    );
  }
}
