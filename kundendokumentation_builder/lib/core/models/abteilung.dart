// lib/core/models/abteilung.dart
class Abteilung {
  final int id;
  final String name;

  Abteilung({required this.id, required this.name});

  factory Abteilung.fromJson(Map<String, dynamic> json) {
    return Abteilung(id: json['id'], name: json['name']);
  }
}
