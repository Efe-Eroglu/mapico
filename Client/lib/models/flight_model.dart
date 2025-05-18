class FlightModel {
  final int id;
  final String title;
  final String description;

  FlightModel({
    required this.id,
    required this.title,
    required this.description,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
} 