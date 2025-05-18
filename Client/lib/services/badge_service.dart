import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapico/models/badge_model.dart';

class BadgeService {
  // API URL değişkeni - hem localhost hem de emülatör için
  static String get _baseUrl {
    // Emülatör için IP adresi (Android emülatör)
    const emulatorUrl = 'http://10.0.2.2:8000/api/v1';
    // Alternatif olarak doğrudan IP adresi  
    const directUrl = 'http://127.0.0.1:8000/api/v1';
    
    // Emülatör URL'ini kullan
    return emulatorUrl;
  }

  // Tüm rozetleri getir
  Future<(List<BadgeModel>?, String?)> getAllBadges([String? token]) async {
    final url = Uri.parse('$_baseUrl/badges');
    
    try {
      print('Badge API isteği yapılıyor: $url');
      if (token != null) print('Token ile istek yapılıyor');
      else print('Token olmadan istek yapılıyor');
      
      final headers = token != null 
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};
      
      final response = await http.get(url, headers: headers);
      
      print('Badge API yanıtı: Status: ${response.statusCode}, Body: ${response.body}');
      
      if (response.statusCode == 200) {
        // API içerik kontrolü
        if (response.body.isEmpty) {
          print('API yanıtı boş');
          return (<BadgeModel>[], null); // Boş liste döndür, error yok
        }
        
        try {
          final dynamic data = json.decode(response.body);
          
          // Data null kontrolü
          if (data == null) {
            print('API yanıtı null');
            return (_createFallbackBadges(), null);
          }
          
          // Burada direkt veriyi kontrol edelim
          if (data is List) {
            // Liste döndüyse, her öğeyi BadgeModel'e dönüştür
            final badges = <BadgeModel>[];
            for (var item in data) {
              try {
                if (item != null && item is Map<String, dynamic>) {
                  badges.add(BadgeModel.fromJson(item));
                }
              } catch (e) {
                print('Tek rozet parse hatası: $e');
                // Hatalı öğeyi atla ve devam et
              }
            }
            
            print('${badges.length} rozet başarıyla yüklendi');
            if (badges.isEmpty && data.isNotEmpty) {
              // Liste doluydu ama hiçbir rozet parse edilemedi
              print('API yanıtı vardı ama hiçbir rozet parse edilemedi');
              return (_createFallbackBadges(), null);
            }
            return (badges, null);
          } else if (data is Map) {
            // Eğer veri doğrudan bir liste olmayıp iç içe bir objeyse
            // "data", "badges", "items" gibi yaygın alanları kontrol edelim
            Map<String, dynamic> jsonMap = data as Map<String, dynamic>;
            
            // Yaygın kullanılan alan adlarını kontrol et
            for (final field in ['data', 'badges', 'items', 'results']) {
              if (jsonMap.containsKey(field) && jsonMap[field] is List) {
                List<dynamic> itemsList = jsonMap[field] as List;
                final badges = <BadgeModel>[];
                
                for (var item in itemsList) {
                  try {
                    if (item != null && item is Map<String, dynamic>) {
                      badges.add(BadgeModel.fromJson(item));
                    }
                  } catch (e) {
                    print('Nested liste parse hatası: $e');
                  }
                }
                
                print('${badges.length} rozet iç listeden başarıyla yüklendi');
                if (badges.isNotEmpty) {
                  return (badges, null);
                }
              }
            }
            
            // Tek bir rozet döndürülmüşse
            try {
              final badge = BadgeModel.fromJson(jsonMap);
              print('1 rozet başarıyla yüklendi');
              return (<BadgeModel>[badge], null);
            } catch (e) {
              print('Tekil rozet parse hatası: $e');
              // Burada API'nin gönderdiği veriyi yazdıralım, debug için
              print('API veri yapısı: ${jsonMap.keys.join(', ')}');
              return (_createFallbackBadges(), null);
            }
          } else {
            print('API yanıtı beklenmeyen formatta: $data');
            return (_createFallbackBadges(), null);
          }
        } catch (e) {
          print('JSON decode hatası: $e');
          // JSON decode edilemese bile, içeriği manuel olarak ayrıştırmayı deneyelim
          final rawData = response.body;
          
          try {
            // Raw response'u farklı şekillerde ayrıştırma denemeleri
            if (rawData.contains('\"name\"') || rawData.contains('\"icon_url\"')) {
              try {
                // Manuel string ayrıştırma
                String name = 'Adsız Rozet';
                String iconUrl = '';
                
                // İsim çıkarma
                final nameRegex = RegExp(r'"name"\s*:\s*"([^"]+)"');
                final nameMatch = nameRegex.firstMatch(rawData);
                if (nameMatch != null && nameMatch.groupCount >= 1) {
                  name = nameMatch.group(1) ?? name;
                }
                
                // Icon URL çıkarma
                final iconRegex = RegExp(r'"icon_url"\s*:\s*"([^"]+)"');
                final iconMatch = iconRegex.firstMatch(rawData);
                if (iconMatch != null && iconMatch.groupCount >= 1) {
                  iconUrl = iconMatch.group(1) ?? '';
                }
                
                // Alternatif URL alanı
                if (iconUrl.isEmpty) {
                  final imgRegex = RegExp(r'"image_url"\s*:\s*"([^"]+)"');
                  final imgMatch = imgRegex.firstMatch(rawData);
                  if (imgMatch != null && imgMatch.groupCount >= 1) {
                    iconUrl = imgMatch.group(1) ?? '';
                  }
                }
                
                // Alternatif URL alanı 2
                if (iconUrl.isEmpty) {
                  final imgRegex = RegExp(r'"icon"\s*:\s*"([^"]+)"');
                  final imgMatch = imgRegex.firstMatch(rawData);
                  if (imgMatch != null && imgMatch.groupCount >= 1) {
                    iconUrl = imgMatch.group(1) ?? '';
                  }
                }
                
                // Açıklama çıkarma
                String description = '';
                final descRegex = RegExp(r'"description"\s*:\s*"([^"]+)"');
                final descMatch = descRegex.firstMatch(rawData);
                if (descMatch != null && descMatch.groupCount >= 1) {
                  description = descMatch.group(1) ?? '';
                }

                final badge = BadgeModel(
                  name: name,
                  imageUrl: iconUrl,
                  description: description.isNotEmpty ? description : 'API yanıtından manuel çıkarıldı',
                );
                
                return (<BadgeModel>[badge], null);
              } catch (e) {
                print('Manuel ayrıştırma hatası: $e');
              }
            }
            
            // Hiçbir yöntem başarılı olmazsa, test rozeti döndür
            return (_createFallbackBadges(), null);
          } catch (e) {
            print('Tüm ayrıştırma yöntemleri başarısız: $e');
            return (_createFallbackBadges(), null);
          }
        }
      } else {
        String errorMsg = 'Rozet listesi alınamadı: HTTP ${response.statusCode}';
        try {
          final data = json.decode(response.body);
          if (data is Map && data['detail'] != null) {
            errorMsg = data['detail'].toString();
          }
        } catch (e) {
          print('API yanıtı JSON formatında değil: ${response.body}');
        }
        print('Get all badges failed: ${response.statusCode} - ${response.body}');
        return (null, errorMsg);
      }
    } catch (e) {
      print('Badge API isteğinde hata: $e');
      return (null, 'Bağlantı hatası: $e');
    }
  }

  // Test rozeti oluştur - API yanıtı düzgün çalışmadığında
  List<BadgeModel> _createFallbackBadges() {
    return <BadgeModel>[
      BadgeModel(
        id: 999, 
        name: 'Test Rozeti', 
        description: 'API yanıtını işlerken bir sorun oluştuğu için bu test rozeti gösteriliyor.',
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/1053/1053367.png',
        category: 'Test',
        pointValue: 5,
      ),
    ];
  }

  // Tek bir rozeti ID'ye göre getir
  Future<(BadgeModel?, String?)> getBadge(String token, int badgeId) async {
    final url = Uri.parse('$_baseUrl/badges/$badgeId');
    
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          
          if (data is List) {
            // Listeden ID'ye göre rozeti bul
            for (var item in data) {
              if (item is Map<String, dynamic> && 
                  item['id'] != null && 
                  item['id'] == badgeId) {
                return (BadgeModel.fromJson(item), null);
              }
            }
            return (null, 'Belirtilen ID ile rozet bulunamadı');
          } else if (data is Map<String, dynamic>) {
            // Tek bir rozet verisi
            if (data['id'] == badgeId) {
              return (BadgeModel.fromJson(data), null);
            }
            // Nested data
            for (final field in ['data', 'badges', 'items', 'results']) {
              if (data.containsKey(field) && data[field] is List) {
                List items = data[field] as List;
                for (var item in items) {
                  if (item is Map<String, dynamic> && 
                      item['id'] != null && 
                      item['id'] == badgeId) {
                    return (BadgeModel.fromJson(item), null);
                  }
                }
              }
            }
            return (null, 'Belirtilen ID ile rozet bulunamadı');
          }
          
          return (null, 'Rozet verisi uygun formatta değil');
        } catch (e) {
          print('JSON decode hatası: $e');
          // Fallback badge
          final fallbackBadge = BadgeModel(
            id: badgeId,
            name: 'Rozet #$badgeId',
            description: 'API yanıtını işlerken bir sorun oluştu.',
            imageUrl: 'https://cdn-icons-png.flaticon.com/512/1053/1053367.png',
          );
          return (fallbackBadge, null);
        }
      } else {
        String errorMsg = 'Rozet bilgisi alınamadı';
        try {
          final data = json.decode(response.body);
          if (data is Map && data['detail'] != null) {
            errorMsg = data['detail'].toString();
          }
        } catch (_) {}
        print('Get badge failed: ${response.statusCode} - ${response.body}');
        return (null, errorMsg);
      }
    } catch (e) {
      print('Get badge exception: $e');
      return (null, 'Bağlantı hatası: $e');
    }
  }
  
  // API test metodu - bağlantı kurulabiliyor mu diye test etmek için
  Future<String> testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/badges');
      print('API test isteği yapılıyor: $url');
      
      final response = await http.get(url);
      print('Test yanıtı: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        String responseDetails = 'API yanıt veriyor: ${response.statusCode}';
        
        // API içeriğini anlamaya çalış
        if (response.body.isNotEmpty) {
          try {
            final data = json.decode(response.body);
            responseDetails += '\nİçerik türü: ${data.runtimeType}';
            if (data is List) {
              responseDetails += '\nListe uzunluğu: ${data.length}';
            } else if (data is Map) {
              responseDetails += '\nMap anahtarları: ${(data as Map).keys.join(', ')}';
            }
          } catch (e) {
            responseDetails += '\nJSON parse edilemedi: $e';
          }
        } else {
          responseDetails += '\nİçerik boş';
        }
        
        return responseDetails;
      } else {
        return 'API hata kodu döndürdü: ${response.statusCode}\n${response.body}';
      }
    } catch (e) {
      print('API test hatası: $e');
      return 'API hatası: $e';
    }
  }
} 