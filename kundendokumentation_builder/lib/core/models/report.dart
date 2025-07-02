class Report {
  final int? id; // Optional, falls nicht immer gesetzt
  final String titel;
  final String beschreibung;
  final DateTime datum;
  final int anlageId;
  

  Report({
    this.id,
    required this.titel,
    required this.beschreibung,
    required this.datum,
    required this.anlageId,
  
  });

  Map<String, dynamic> toJson() => {
    'titel': titel,
    'beschreibung': beschreibung,
    'erstellt_am': datum.toIso8601String(),
    'anlage_id': anlageId,
  };

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      titel: json['titel'],
      beschreibung: json['beschreibung'],
      datum: DateTime.parse(json['erstellt_am']),
      anlageId: json['anlage_id'],
    );
  }
}
