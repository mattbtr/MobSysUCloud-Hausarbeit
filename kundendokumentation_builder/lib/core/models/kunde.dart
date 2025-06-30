// lib/core/models/kunde.dart

class Kunde{
  final int id;
  final String name;

  Kunde({required this.id, required this.name});

  factory Kunde.fromJson(Map<String, dynamic> json){
    return Kunde(id: json['id'], name: json['name']);
  }
}
