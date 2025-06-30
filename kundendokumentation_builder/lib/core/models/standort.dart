// lib/core/models/Standort.dart
class Standort {
  final int id;
  final String name;
  final String adresse;

  Standort({required this.id, required this.name, required this.adresse});

  factory Standort.fromJson(Map<String, dynamic> json) {
    return Standort(id: json['id'], name: json['name'], adresse: json['adresse']);
  }
}
