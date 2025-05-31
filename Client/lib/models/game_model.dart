class GameModel {
  final int id;
  final String name;
  final String title;
  final String? description;
  final DateTime createdAt;
  final String? code; // Oyun kodu

  GameModel({
    required this.id,
    required this.name,
    required this.title,
    this.description,
    this.code,
    required this.createdAt,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      description: json['description'],
      code: json['code'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'code': code,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
