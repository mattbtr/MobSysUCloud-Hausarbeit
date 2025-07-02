class Stammdaten {
  final Map<String, dynamic> kunde;
  final Map<String, dynamic> standort;
  final Map<String, dynamic> abteilung;
  final Map<String, dynamic> anlage;

  Stammdaten({
    required this.kunde,
    required this.standort,
    required this.abteilung,
    required this.anlage,
  });

  factory Stammdaten.fromJson(Map<String, dynamic> json) {
    return Stammdaten(
      kunde: json['kunde'],
      standort: json['standort'],
      abteilung: json['abteilung'],
      anlage: json['anlage'],
    );
  }
}
