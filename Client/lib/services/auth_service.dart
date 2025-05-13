import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapico/models/user_model.dart';

class AuthService {
        static const String _baseUrl = 'http://10.0.2.2:8000/api/v1';

  Future<String?> login({required String username, required String password}) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      print('Login failed: \\${response.statusCode} - \\${response.body}');
      return null;
    }
  }

  Future<(UserModel?, String?)> register({
    required String email,
    required String fullName,
    required String dateOfBirth,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'full_name': fullName,
        'date_of_birth': dateOfBirth,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return (UserModel.fromJson(data), null);
    } else {
      // Hata mesajını ayrıştır
      String errorMsg = 'Kayıt başarısız';
      try {
        final data = json.decode(response.body);
        if (data is Map && data['detail'] != null) {
          if (data['detail'] is List && data['detail'].isNotEmpty && data['detail'][0]['msg'] != null) {
            errorMsg = data['detail'][0]['msg'];
          } else if (data['detail'] is String) {
            errorMsg = data['detail'];
          }
        }
      } catch (_) {}
      print('Register failed: \\${response.statusCode} - \\${response.body}');
      return (null, errorMsg);
    }
  }
} 