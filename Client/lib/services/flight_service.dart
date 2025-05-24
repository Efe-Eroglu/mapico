import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapico/models/flight_model.dart';

class FlightService {
  // API URL - hem localhost hem de emülatör (10.0.2.2) formatını desteklesin
  static String get _baseUrl {
    // Önce 10.0.2.2 ile denesin (Android emülatör)
    const emulatorUrl = 'http://34.31.239.252:8000/api/v1';
    // Alternatif olarak doğrudan IP adresi
    const directUrl = 'http://34.31.239.252:8000/api/v1';

    return emulatorUrl;
  }

  // Get all flights - token opsiyonel yaparak test edebiliriz
  Future<(List<FlightModel>?, String?)> getAllFlights([String? token]) async {
    final url = Uri.parse('$_baseUrl/flights');

    try {
      print('Flight API isteği yapılıyor: $url');
      if (token != null)
        print('Token ile istek yapılıyor');
      else
        print('Token olmadan istek yapılıyor (test modu)');

      final headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};

      final response = await http.get(url, headers: headers);

      print(
          'Flight API yanıtı: Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          final flights = data.map((e) => FlightModel.fromJson(e)).toList();
          print('${flights.length} uçuş başarıyla yüklendi');
          return (flights, null);
        } else {
          print('API yanıtı liste formatında değil: $data');
          return (null, 'Uçuş listesi alınamadı: Yanlış veri formatı');
        }
      } else {
        String errorMsg = 'Uçuş listesi alınamadı: HTTP ${response.statusCode}';
        try {
          final data = json.decode(response.body);
          if (data is Map && data['detail'] != null) {
            errorMsg = data['detail'].toString();
          }
        } catch (e) {
          print('API yanıtı JSON formatında değil: ${response.body}');
        }
        print(
            'Get all flights failed: ${response.statusCode} - ${response.body}');
        return (null, errorMsg);
      }
    } catch (e) {
      print('Flight API isteğinde hata: $e');
      return (null, 'Bağlantı hatası: $e');
    }
  }

  // Get a single flight by ID
  Future<(FlightModel?, String?)> getFlight(String token, int flightId) async {
    final url = Uri.parse('$_baseUrl/flights/$flightId');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (FlightModel.fromJson(data), null);
      } else {
        String errorMsg = 'Uçuş bilgisi alınamadı';
        try {
          final data = json.decode(response.body);
          if (data is Map && data['detail'] != null) {
            errorMsg = data['detail'].toString();
          }
        } catch (_) {}
        print('Get flight failed: ${response.statusCode} - ${response.body}');
        return (null, errorMsg);
      }
    } catch (e) {
      print('Get flight exception: $e');
      return (null, 'Bağlantı hatası: $e');
    }
  }

  // API test metodu - bağlantı kurulabiliyor mu diye test etmek için
  Future<String> testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/flights');
      print('API test isteği yapılıyor: $url');

      final response = await http.get(url);
      print('Test yanıtı: ${response.statusCode} - ${response.body}');

      return 'API yanıt veriyor: ${response.statusCode}\n${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}';
    } catch (e) {
      print('API test hatası: $e');
      return 'API hatası: $e';
    }
  }
}
