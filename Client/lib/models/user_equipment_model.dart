import 'package:mapico/models/equipment_model.dart';

class UserEquipmentModel {
  final int id;
  final int userId;
  final int equipmentId;
  final DateTime selectedAt;
  final EquipmentModel? equipment;

  UserEquipmentModel({
    required this.id,
    required this.userId,
    required this.equipmentId,
    required this.selectedAt,
    this.equipment,
  });

  factory UserEquipmentModel.fromJson(Map<String, dynamic> json) {
    // Debug için json içeriğini yazdır
    print('UserEquipmentModel.fromJson: $json');
    
    return UserEquipmentModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      equipmentId: json['equipment_id'] ?? 0,
      selectedAt: json['selected_at'] != null 
          ? DateTime.parse(json['selected_at']) 
          : DateTime.now(),
      equipment: json['equipment'] != null 
          ? EquipmentModel.fromJson(json['equipment']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'equipment_id': equipmentId,
      'selected_at': selectedAt.toIso8601String(),
    };
  }
} 