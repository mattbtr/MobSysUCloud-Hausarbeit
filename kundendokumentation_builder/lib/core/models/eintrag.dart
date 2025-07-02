class Eintrag {
  final int id;
  final String titel;
  final String? beschreibung;
  final String? wert;
  final int berichtId;
  final bool? hasImage;

  Eintrag({
    required this.id,
    required this.titel,
    this.beschreibung,
    this.wert,
    required this.berichtId,
    this.hasImage,
  });

  factory Eintrag.fromJson(Map<String, dynamic> json) {
    return Eintrag(
      id: json['id'],
      titel: json['titel'],
      beschreibung: json['beschreibung'],
      wert: json['wert'],
      berichtId: json['bericht_id'],
      hasImage: json['has_image'] ?? false,
    );
  }
}
