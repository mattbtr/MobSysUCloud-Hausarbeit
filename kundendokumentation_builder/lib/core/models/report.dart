class Report {
  final String titel;
  final String beschreibung;
  final String status;
  final DateTime datum;
  final int anlageId;
  final String messwerte;
  final List<String> bilder; // Base64 oder URLs

  Report({
    required this.titel,
    required this.beschreibung,
    required this.status,
    required this.datum,
    required this.anlageId,
    required this.messwerte,
    required this.bilder,
  });

  Map<String, dynamic> toJson() => {
    'titel': titel,
    'beschreibung': beschreibung,
    'status': status,
    'datum': datum.toIso8601String(),
    'anlage_id': anlageId,
    'wert': messwerte,
    'bilder': bilder,
  };
}
