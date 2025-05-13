class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String dateOfBirth;
  final int? age;
  final bool isActive;
  final bool isSuperuser;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.dateOfBirth,
    this.age,
    required this.isActive,
    required this.isSuperuser,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      dateOfBirth: json['date_of_birth'],
      age: json['age'],
      isActive: json['is_active'],
      isSuperuser: json['is_superuser'],
    );
  }
}
