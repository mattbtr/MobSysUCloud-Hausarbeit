class Report {
  final String id;
  final String title;
  final DateTime createdAt;

  Report({required this.id, required this.title, required this.createdAt});

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id'],
    title: json['title'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
  };
}
