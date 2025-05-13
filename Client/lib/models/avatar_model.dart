class AvatarModel {
  final int id;
  final String name;
  final String imageUrl;
  final String description;

  AvatarModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      description: json['description'],
    );
  }
} 