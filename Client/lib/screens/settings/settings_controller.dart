import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsController extends GetxController {
  final Rxn<Map<String, dynamic>> userInfo = Rxn<Map<String, dynamic>>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      isLoading.value = true;
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token == null) return;
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/v1/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        userInfo.value = json.decode(response.body);
      }
    } catch (e) {
      print('Kullanıcı bilgisi alınamadı: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
    Get.offAllNamed('/login');
  }
} 