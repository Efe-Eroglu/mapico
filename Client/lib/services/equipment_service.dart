import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapico/models/equipment_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EquipmentService {
  // 10.0.2.2, Android emülatörlerinde localhost'a denk gelir
  // Gerçek bir cihazda test ediyorsanız bilgisayarınızın gerçek IP adresini kullanın (ör: 192.168.1.X)
  final String baseUrl = 'http://34.31.239.252:8000/api/v1';
  final storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  // Tüm ekipmanları getir
  Future<(List<EquipmentModel>?, String?)> getAllEquipment() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return (null, 'Oturum bulunamadı');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/equipment/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final equipment =
            data.map((json) => EquipmentModel.fromJson(json)).toList();
        return (equipment, null);
      } else {
        return (
          null,
          'Ekipmanlar yüklenirken bir hata oluştu - Status: ${response.statusCode}'
        );
      }
    } catch (e) {
      print('Hata detayı: $e');
      return (null, 'Bağlantı hatası: $e');
    }
  }
}
