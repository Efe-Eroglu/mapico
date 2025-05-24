import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapico/models/user_model.dart';
import 'package:mapico/models/avatar_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  Future<String?> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
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
      headers: {'Content-Type': 'application/json'},
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
          if (data['detail'] is List &&
              data['detail'].isNotEmpty &&
              data['detail'][0]['msg'] != null) {
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

  Future<(AvatarModel?, String?)> getAvatar(String token) async {
    final url = Uri.parse('$_baseUrl/avatars/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List && data.isNotEmpty) {
        return (AvatarModel.fromJson(data[0]), null);
      } else {
        return (null, 'Avatar bulunamadı');
      }
    } else {
      String errorMsg = 'Avatar alınamadı';
      try {
        final data = json.decode(response.body);
        if (data is Map && data['detail'] != null) {
          errorMsg = data['detail'].toString();
        }
      } catch (_) {}
      print('Get avatar failed: \\${response.statusCode} - \\${response.body}');
      return (null, errorMsg);
    }
  }

  // Kullanıcının avatarını getir
  Future<(AvatarModel?, String?)> getUserAvatar(String token) async {
    final url = Uri.parse('$_baseUrl/users/me/avatar');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (AvatarModel.fromJson(data['avatar']), null);
    } else {
      String errorMsg = 'Avatar alınamadı';
      try {
        final data = json.decode(response.body);
        if (data is Map && data['detail'] != null) {
          errorMsg = data['detail'].toString();
        }
      } catch (_) {}
      print(
        'Get user avatar failed: \\${response.statusCode} - \\${response.body}',
      );
      return (null, errorMsg);
    }
  }

  // Tüm avatarları listele
  Future<(List<AvatarModel>, String?)> getAllAvatars(String token) async {
    final url = Uri.parse('$_baseUrl/avatars/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return (data.map((e) => AvatarModel.fromJson(e)).toList(), null);
      } else {
        return (<AvatarModel>[], 'Avatar listesi alınamadı');
      }
    } else {
      String errorMsg = 'Avatar listesi alınamadı';
      try {
        final data = json.decode(response.body);
        if (data is Map && data['detail'] != null) {
          errorMsg = data['detail'].toString();
        }
      } catch (_) {}
      print(
        'Get all avatars failed: \\${response.statusCode} - \\${response.body}',
      );
      return (<AvatarModel>[], errorMsg);
    }
  }

  // Kullanıcı avatarını güncelle
  Future<String?> updateUserAvatar(String token, int avatarId) async {
    final url = Uri.parse('$_baseUrl/users/me/avatar');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'avatar_id': avatarId}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return null; // Başarılı
    } else {
      String errorMsg = 'Avatar güncellenemedi';
      try {
        final data = json.decode(response.body);
        if (data is Map && data['detail'] != null) {
          errorMsg = data['detail'].toString();
        }
      } catch (_) {}
      print(
        'Update user avatar failed: \\${response.statusCode} - \\${response.body}',
      );
      return errorMsg;
    }
  }

  Future<(UserModel?, String?)> getCurrentUser(String token) async {
    final url = Uri.parse('$_baseUrl/auth/me');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (UserModel.fromJson(data), null);
    } else {
      String errorMsg = 'Kullanıcı bilgisi alınamadı';
      try {
        final data = json.decode(response.body);
        if (data is Map && data['detail'] != null) {
          errorMsg = data['detail'].toString();
        }
      } catch (_) {}
      print(
        'Get current user failed: \\${response.statusCode} - \\${response.body}',
      );
      return (null, errorMsg);
    }
  }
}
