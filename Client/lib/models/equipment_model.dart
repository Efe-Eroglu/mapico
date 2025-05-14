class EquipmentModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String? category;

  EquipmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.category,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['icon_url'] ?? json['imageUrl'] ?? '',
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': imageUrl,
      'category': category,
    };
  }
} 