// lib/core/models/anlage.dart
class Anlage {
  final int id;
  final String name;

  Anlage({required this.id, required this.name});

  factory Anlage.fromJson(Map<String, dynamic> json) {
    return Anlage(id: json['id'], name: json['name']);
  }
}
