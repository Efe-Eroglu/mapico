import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:mapico/models/user_badge_model.dart';
import 'package:mapico/models/badge_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserBadgeService {
  // API URL değişkeni - .env dosyasından alınır
  static String get _baseUrl {
    try {
      // .env dosyasından farklı olası değişken adları kontrol edilir
      final possibleKeys = [
        'API_BASE_URL', 
        'API_URL', 
        'REACT_APP_API_URL', 
        'BACKEND_URL',
        'MAPICO_API_URL'
      ];
      
      String? configUrl;
      for (final key in possibleKeys) {
        final value = dotenv.env[key];
        if (value != null && value.isNotEmpty) {
          configUrl = value;
          print('$key değişkeni ile API URL bulundu: $value');
          break;
        }
      }
      
      // Eğer configUrl null veya boş ise kullanıcı uyarılır
      if (configUrl == null || configUrl.isEmpty) {
        print('UYARI: .env dosyasında API URL değişkeni bulunamadı!');
        print('Aşağıdaki değişkenlerden birini .env dosyasına ekleyin:');
        print('Şimdilik varsayılan URL kullanılacak.');
        return 'http://10.0.2.2:8000/api/v1';
      }
      
      // URL'nin sonunda /api/v1 olup olmadığını kontrol et
      if (!configUrl.endsWith('/api/v1')) {
        // URL'nin sonunda / var mı kontrol et
        if (configUrl.endsWith('/')) {
          configUrl += 'api/v1';
        } else {
          configUrl += '/api/v1';
        }
        print('API URL path eklendi: $configUrl');
      }
      
      print('Kullanılan API URL: $configUrl');
      return configUrl;
    } catch (e) {
      print('API URL alma hatası: $e');
      return 'http://10.0.2.2:8000/api/v1';
    }
  }

  // Token'ı güvenli depodan alma yardımcı metodu
  Future<String?> _getToken() async {
    try {
      const storage = FlutterSecureStorage();
      return await storage.read(key: 'jwt_token');
    } catch (e) {
      print('Token okuma hatası: $e');
      return null;
    }
  }

  // Bir kullanıcının tüm rozetlerini getir
  Future<(List<UserBadgeModel>?, String?)> getUserBadges(int userId,
      [String? token]) async {
    var url = Uri.parse('$_baseUrl/user_badges/$userId');

    try {
      print('UserBadge API isteği yapılıyor: $url');
      print('Kullanıcı ID: $userId');
      final headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};

      print('Headers: $headers');

      final response = await http.get(url, headers: headers);

      print(
          'UserBadge API yanıtı: Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final dynamic data = json.decode(response.body);

          // Yeni format: {"user_info": {...}, "badges": [...]}
          if (data is Map<String, dynamic> && data.containsKey('badges')) {
            final badges = data['badges'];

            if (badges is List) {
              final userBadges = <UserBadgeModel>[];
              for (var item in badges) {
                if (item != null && item is Map<String, dynamic>) {
                  try {
                    // API'den gelen badge_id, user_id, ve id'yi kullanarak UserBadgeModel oluştur
                    final badgeId = item['badge_id'] ?? 0;

                    // UserBadgeModel oluştur ve ekle
                    final userBadge = UserBadgeModel(
                      id: item['id'] ?? 0,
                      userId: item['user_id'] ?? userId,
                      badgeId: badgeId,
                      earnedDate: item['awarded_at'] ?? '',
                      badge: null, // Badge detayları ayrıca alınacak
                    );

                    print('Rozet ayrıştırıldı: ID=${userBadge.id}, '
                        'userID=${userBadge.userId}, '
                        'badgeID=${userBadge.badgeId}, '
                        'date=${userBadge.earnedDate}');

                    userBadges.add(userBadge);
                  } catch (e) {
                    print('Rozet ayrıştırma hatası: $e');
                  }
                }
              }

              print('${userBadges.length} rozet ayrıştırıldı');
              
              // Rozet detaylarını almak için yeni endpoint'e istek yap
              if (userBadges.isNotEmpty) {
                await _loadAllBadgeDetails(userBadges, token);
              }
              
              return (userBadges, null);
            }
          }

          // Eski format denemesi - daha genel yaklaşım
          if (data is List) {
            final userBadges = <UserBadgeModel>[];
            for (var item in data) {
              if (item != null && item is Map<String, dynamic>) {
                userBadges.add(UserBadgeModel.fromJson(item));
              }
            }
            
            // Rozet detaylarını almak için yeni endpoint'e istek yap
            if (userBadges.isNotEmpty) {
              await _loadAllBadgeDetails(userBadges, token);
            }
            
            return (userBadges, null);
          }
          // Bir obje olarak döndüyse
          else if (data is Map<String, dynamic>) {
            // Tek bir rozet olarak alın
            final userBadge = UserBadgeModel.fromJson(data);
            
            // Rozet detaylarını almak için yeni endpoint'e istek yap
            await _loadAllBadgeDetails([userBadge], token);
            
            return (<UserBadgeModel>[userBadge], null);
          }
          // Boş veya geçersiz veri
          else {
            return (<UserBadgeModel>[], null);
          }
        } catch (e) {
          print('JSON parse hatası: $e');
          return (null, 'Veri çözümlenirken hata oluştu: $e');
        }
      }
      // Kullanıcının rozeti yok (404 durumu normal)
      else if (response.statusCode == 404) {
        print('Kullanıcının rozeti bulunmuyor (404)');
        return (<UserBadgeModel>[], null);
      }
      // Diğer hata durumları
      else {
        String errorMsg = 'API Hatası: HTTP ${response.statusCode}';
        try {
          final data = json.decode(response.body);
          if (data is Map && data['detail'] != null) {
            errorMsg = data['detail'].toString();
          }
        } catch (e) {
          print('Hata yanıtı parse edilemedi: $e');
        }
        return (null, errorMsg);
      }
    } catch (e) {
      print('Bağlantı hatası: $e');
      return (null, 'Bağlantı hatası: $e');
    }
  }
  
  // Tüm rozet detaylarını tek bir API isteği ile al ve eşleştir
  Future<void> _loadAllBadgeDetails(List<UserBadgeModel> userBadges, [String? token]) async {
    try {
      // Tüm rozetlerin detaylarını al
      print('Tüm rozet detayları için API isteği yapılıyor');
      final url = Uri.parse('$_baseUrl/badges');
      
      final headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};
          
      final response = await http.get(url, headers: headers)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Rozet detayları isteği zaman aşımına uğradı');
            return http.Response('{"error":"timeout"}', 408);
          },
        );
      
      if (response.statusCode == 200) {
        print('Tüm rozetler başarıyla alındı');
        try {
          final List<dynamic> badgesList = json.decode(response.body);
          
          if (badgesList.isNotEmpty) {
            // Rozet ID'lerine göre eşleştirme haritası oluştur
            final badgesMap = <int, BadgeModel>{};
            
            for (var badgeData in badgesList) {
              if (badgeData != null && badgeData is Map<String, dynamic>) {
                try {
                  final id = badgeData['id'] as int?;
                  if (id != null) {
                    // API'den dönen badge formatı:
                    // {"name":"Minik Kaşif", "icon_url":"url", "criteria":{"min_score":100}, "id":2}
                    final badge = BadgeModel(
                      id: id,
                      name: badgeData['name'] ?? 'Rozet #$id',
                      description: badgeData['description'] ?? 
                        'Puan: ${badgeData['criteria']?['min_score'] ?? '100'} veya üzeri',
                      imageUrl: badgeData['icon_url'] ?? '',
                      pointValue: badgeData['criteria']?['min_score'] ?? 100,
                      category: badgeData['category'] ?? _getCategoryForBadgeId(id),
                    );
                    
                    badgesMap[id] = badge;
                    print('Rozet detayı alındı: ${badge.name} (ID: $id)');
                  }
                } catch (e) {
                  print('Badge ayrıştırma hatası: $e');
                }
              }
            }
            
            print('${badgesMap.length} rozet detayı başarıyla ayrıştırıldı');
            
            // Kullanıcı rozetlerini eşleştir
            for (int i = 0; i < userBadges.length; i++) {
              final userBadge = userBadges[i];
              if (userBadge.badge == null && badgesMap.containsKey(userBadge.badgeId)) {
                // Rozeti güncelle
                userBadges[i] = UserBadgeModel(
                  id: userBadge.id,
                  userId: userBadge.userId,
                  badgeId: userBadge.badgeId,
                  earnedDate: userBadge.earnedDate,
                  badge: badgesMap[userBadge.badgeId],
                );
                print('Kullanıcı rozeti güncellendi: ID ${userBadge.badgeId}');
              }
            }
          }
        } catch (e) {
          print('Rozet listesi ayrıştırma hatası: $e');
          _assignFallbackBadges(userBadges);
        }
      } else {
        print('Rozet detayları alınamadı - HTTP ${response.statusCode}');
        _assignFallbackBadges(userBadges);
      }
    } catch (e) {
      print('Tüm rozet detaylarını alma hatası: $e');
      _assignFallbackBadges(userBadges);
    }
  }
  
  // Fallback rozet detayları atar
  void _assignFallbackBadges(List<UserBadgeModel> userBadges) {
    print('Fallback rozet detayları atanıyor...');
    
    for (int i = 0; i < userBadges.length; i++) {
      final userBadge = userBadges[i];
      if (userBadge.badge == null) {
        // Fallback rozet oluştur
        userBadges[i] = UserBadgeModel(
          id: userBadge.id,
          userId: userBadge.userId,
          badgeId: userBadge.badgeId,
          earnedDate: userBadge.earnedDate,
          badge: _createFallbackBadge(userBadge.badgeId),
        );
        print('Fallback rozet atandı: ID ${userBadge.badgeId}');
      }
    }
  }

  // Bir kullanıcıya rozet ata
  Future<(bool, String?)> assignBadge(int badgeId, [String? token]) async {
    try {
      // Token yoksa güvenli depodan al
      token ??= await _getToken();
      if (token == null) {
        return (false, 'Oturum bilgisi bulunamadı');
      }

      final url = Uri.parse('$_baseUrl/user_badges');

      print('Badge atama isteği yapılıyor: $url');
      print('Rozet ID: $badgeId');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      print('Headers: $headers');

      // userId'i göndermiyoruz, API tarafında token'dan alınacak
      final body = jsonEncode({
        'badge_id': badgeId,
      });

      print('Request body: $body');

      final response = await http.post(url, headers: headers, body: body);

      print(
          'Badge atama yanıtı: Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, 'Rozet başarıyla atandı');
      } else {
        String errorMsg = 'Rozet atanamadı: HTTP ${response.statusCode}';
        try {
          final data = json.decode(response.body);
          if (data is Map && data['detail'] != null) {
            errorMsg = data['detail'].toString();
          }
        } catch (e) {
          print('API yanıtı JSON formatında değil: ${response.body}');
        }
        print('Assign badge failed: ${response.statusCode} - ${response.body}');
        return (false, errorMsg);
      }
    } catch (e) {
      print('Badge atama isteğinde hata: $e');
      return (false, 'Bağlantı hatası: $e');
    }
  }

  // Belirli bir rozetin detaylarını getir
  Future<BadgeModel?> getBadgeDetail(int badgeId, [String? token]) async {
    try {
      // Doğrudan tek rozet için endpoint
      final url = Uri.parse('$_baseUrl/badges/$badgeId');

      final headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};

      print('Rozet detayı isteniyor: $url');
      
      // Timeout ekleyerek istek uzun sürerse iptal edelim
      final response = await http.get(url, headers: headers)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('Rozet detayı isteği zaman aşımına uğradı');
              return http.Response('{"error":"timeout"}', 408);
            },
          );

      print('Rozet detayı yanıtı: Status ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Rozet detay içeriği: ${response.body}');
        try {
          final data = json.decode(response.body);
          if (data != null && data is Map<String, dynamic>) {
            // API formatı: {"name":"Rozet Adı", "icon_url":"url", "criteria":{"min_score":100}, "id":2}
            final badge = BadgeModel(
              id: data['id'] ?? badgeId,
              name: data['name'] ?? 'Rozet #$badgeId',
              description: data['description'] ?? 
                'Puan: ${data['criteria']?['min_score'] ?? '100'} veya üzeri',
              imageUrl: data['icon_url'] ?? '',
              pointValue: data['criteria']?['min_score'] ?? 100,
              category: data['category'] ?? _getCategoryForBadgeId(badgeId),
            );
            
            print('Rozet detayı başarıyla ayrıştırıldı: ${badge.name}');
            return badge;
          } else {
            print('Rozet detay verisi beklenmeyen formatta: $data');
          }
        } catch (e) {
          print('Rozet detayı JSON ayrıştırma hatası: $e');
        }
      } else {
        print('Rozet detay isteği başarısız: ${response.statusCode}');
      }

      // Eğer API çağrısı başarısız olduysa örnek bir rozet oluştur
      return _createFallbackBadge(badgeId);
    } catch (e) {
      print('Rozet detayı alınırken beklenmeyen hata: $e');
      return _createFallbackBadge(badgeId);
    }
  }
  
  // API'den detay alınamadığında kullanılacak fallback rozet oluşturur
  BadgeModel _createFallbackBadge(int badgeId) {
    // Farklı rozet tipleri için farklı simgeler kullanabiliriz
    String imageUrl;
    String name;
    String description;
    
    // Badge ID'sine göre farklı rozet tipleri
    switch (badgeId % 5) {
      case 0:
        imageUrl = 'https://cdn-icons-png.flaticon.com/512/4842/4842091.png';
        name = 'Keşif Rozeti #$badgeId';
        description = 'Yeni yerler keşfederek kazanılan bir rozet.';
        break;
      case 1:
        imageUrl = 'https://cdn-icons-png.flaticon.com/512/3113/3113022.png';
        name = 'Başarı Rozeti #$badgeId';
        description = 'Özel görevleri tamamlayarak kazanılan bir rozet.';
        break;
      case 2:
        imageUrl = 'https://cdn-icons-png.flaticon.com/512/9578/9578904.png';
        name = 'İlerleme Rozeti #$badgeId';
        description = 'Uygulamayı düzenli kullanarak kazanılan bir rozet.';
        break;
      case 3:
        imageUrl = 'https://cdn-icons-png.flaticon.com/512/6941/6941697.png';
        name = 'Etkinlik Rozeti #$badgeId';
        description = 'Özel etkinliklere katılarak kazanılan bir rozet.';
        break;
      case 4:
        imageUrl = 'https://cdn-icons-png.flaticon.com/512/4329/4329082.png';
        name = 'Koleksiyon Rozeti #$badgeId';
        description = 'Eşsiz koleksiyon parçalarını tamamlayarak kazanılan bir rozet.';
        break;
      default:
        imageUrl = 'https://cdn-icons-png.flaticon.com/512/1053/1053367.png';
        name = 'Rozet #$badgeId';
        description = 'Bu rozet için detay bilgisi alınamıyor.';
    }
    
    print('Fallback rozet oluşturuldu: $name');
    return BadgeModel(
      id: badgeId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      pointValue: badgeId * 10, // Her rozet için farklı bir puan
      category: _getCategoryForBadgeId(badgeId),
    );
  }
  
  // Badge ID'sine göre kategori tahmini
  String? _getCategoryForBadgeId(int badgeId) {
    final categories = [
      'Keşif', 
      'Başarı', 
      'İlerleme', 
      'Etkinlik', 
      'Koleksiyon'
    ];
    return categories[badgeId % categories.length];
  }
}
