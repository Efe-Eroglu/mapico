import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapico/models/user_equipment_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserEquipmentService {
  // 10.0.2.2, Android emülatörlerinde localhost'a denk gelir
  // Gerçek bir cihazda test ediyorsanız bilgisayarınızın gerçek IP adresini kullanın (ör: 192.168.1.X)
  final String baseUrl = 'http://10.0.2.2:8000/api/v1'; 
  final storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  // Kullanıcının ekipmanlarını getir
  Future<(List<UserEquipmentModel>?, String?)> getUserEquipments() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return (null, 'Oturum bulunamadı');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/me/equipment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('getUserEquipments response status: ${response.statusCode}');
      print('getUserEquipments response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final equipments = data.map((json) => UserEquipmentModel.fromJson(json)).toList();
        return (equipments, null);
      } else {
        return (null, 'Ekipmanlarınız yüklenirken bir hata oluştu - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('getUserEquipments hata detayı: $e');
      return (null, 'Bağlantı hatası: $e');
    }
  }

  // Kullanıcıya ekipman ekle
  Future<(UserEquipmentModel?, String?)> addUserEquipment(int equipmentId) async {
    try {
      // Önce mevcut ekipmanları kontrol et
      final (userEquipments, error) = await getUserEquipments();
      
      if (error != null) {
        return (null, error);
      }
      
      // Ekipman zaten ekli mi kontrol et
      if (userEquipments != null && userEquipments.any((ue) => ue.equipmentId == equipmentId)) {
        return (null, 'Bu ekipman zaten ekipmanlarınıza eklenmiş');
      }
      
      final token = await _getToken();
      if (token == null) {
        return (null, 'Oturum bulunamadı');
      }

      final requestBody = json.encode({
        'equipment_id': equipmentId,
      });
      
      print('addUserEquipment request body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/users/me/equipment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('addUserEquipment response status: ${response.statusCode}');
      print('addUserEquipment response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final userEquipment = UserEquipmentModel.fromJson(data);
        return (userEquipment, null);
      } else {
        return (null, 'Ekipman eklenirken bir hata oluştu - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('addUserEquipment hata detayı: $e');
      return (null, 'Bağlantı hatası: $e');
    }
  }

  // Kullanıcının ekipmanını sil
  Future<String?> removeUserEquipment(int userEquipmentId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return 'Oturum bulunamadı';
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/users/me/equipment/$userEquipmentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('removeUserEquipment response status: ${response.statusCode}');

      if (response.statusCode == 204) {
        return null;
      } else {
        return 'Ekipman silinirken bir hata oluştu - Status: ${response.statusCode}';
      }
    } catch (e) {
      print('removeUserEquipment hata detayı: $e');
      return 'Bağlantı hatası: $e';
    }
  }
} 