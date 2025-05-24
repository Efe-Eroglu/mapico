import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:mapico/models/user_badge_model.dart';
import 'package:mapico/models/badge_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserBadgeService {
  // API URL değişkeni - hem localhost hem de emülatör için
  static String get _baseUrl {
    // Android emülatörü için doğru URL (10.0.2.2 localhost'a denk gelir)
    const emulatorUrl = 'http://34.31.239.252:8000/api/v1';
    return emulatorUrl;
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
            return (userBadges, null);
          }
          // Bir obje olarak döndüyse
          else if (data is Map<String, dynamic>) {
            // Tek bir rozet olarak alın
            final userBadge = UserBadgeModel.fromJson(data);
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

  // Birden fazla rozet için badge detaylarını getir
  Future<List<BadgeModel>> getBadgeDetails(List<int> badgeIds,
      [String? token]) async {
    final badgeList = <BadgeModel>[];

    if (badgeIds.isEmpty) {
      return badgeList;
    }

    try {
      print('Rozet detayları isteniyor - ID\'ler: $badgeIds');

      // Önce tek tek rozetleri getirmeyi dene - daha güvenilir
      for (final id in badgeIds) {
        print('Rozet ID: $id için detay getiriliyor');
        final badge = await getBadgeDetail(id, token);
        if (badge != null) {
          badgeList.add(badge);
        } else {
          // API'den bilgi alamadıysak, fallback rozet oluştur
          print('Rozet ID: $id için detay alınamadı, fallback kullanılıyor');
          badgeList.add(BadgeModel(
            id: id,
            name: 'Rozet #$id',
            description: 'Rozet bilgileri şu anda alınamıyor.',
            imageUrl: 'https://cdn-icons-png.flaticon.com/512/1053/1053367.png',
          ));
        }
      }
    } catch (e) {
      print('Rozet detayları alınırken hata: $e');

      // Hata durumunda eksik rozetler için fallback oluştur
      if (badgeList.length < badgeIds.length) {
        final foundIds = badgeList.map((b) => b.id).whereType<int>().toSet();
        final missingIds =
            badgeIds.where((id) => !foundIds.contains(id)).toList();

        print(
            '${missingIds.length} rozet detayı eksik, fallback oluşturuluyor');
        for (final id in missingIds) {
          badgeList.add(BadgeModel(
            id: id,
            name: 'Rozet #$id',
            description: 'Rozet bilgileri şu anda alınamıyor.',
            imageUrl: 'https://cdn-icons-png.flaticon.com/512/1053/1053367.png',
          ));
        }
      }
    }

    print('${badgeList.length} rozet detayı başarıyla getirildi');
    return badgeList;
  }

  // Belirli bir rozetin detaylarını getir
  Future<BadgeModel?> getBadgeDetail(int badgeId, [String? token]) async {
    try {
      // Doğrudan tek rozet için endpoint
      final url = Uri.parse('$_baseUrl/badges/$badgeId');

      final headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};

      print('Requesting badge detail: $url');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        print('Badge detail response: ${response.body}');
        try {
          final data = json.decode(response.body);
          if (data != null && data is Map<String, dynamic>) {
            return BadgeModel.fromJson(data);
          }
        } catch (e) {
          print('Badge detail parse error: $e');
        }
      } else {
        print('Badge detail request failed: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      print('Badge detail exception: $e');
      return null;
    }
  }
}
