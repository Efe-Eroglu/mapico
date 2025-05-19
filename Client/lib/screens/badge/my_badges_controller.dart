import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import 'package:mapico/models/user_badge_model.dart';
import 'package:mapico/models/badge_model.dart';
import 'package:mapico/services/user_badge_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:mapico/services/auth_service.dart';
import 'package:mapico/models/user_model.dart';

class MyBadgesController extends BaseController {
  final userBadges = <UserBadgeModel>[].obs;
  final badgeDetails = <BadgeModel>[].obs;
  bool _isLoading = false;
  String? errorMessage;
  
  // Kullanıcı ID'si - dinamik olarak alınacak
  final userId = RxInt(0);
  final authService = AuthService();
  
  final userBadgeService = UserBadgeService();
  
  // Kategori filtresi
  final selectedCategory = RxString('');
  final categories = <String>[].obs;
  
  bool get isLoading => _isLoading;
  
  @override
  void onInit() {
    super.onInit();
    // Önce mevcut oturum açmış kullanıcının bilgilerini al, sonra rozetleri yükle
    _loadCurrentUser();
  }
  
  // Mevcut kullanıcıyı yükle
  Future<void> _loadCurrentUser() async {
    try {
      _isLoading = true;
      update();
      
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      
      if (token == null) {
        errorMessage = 'Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.';
        _isLoading = false;
        update();
        return;
      }
      
      // AuthService ile kullanıcı bilgilerini al
      final (user, error) = await authService.getCurrentUser(token);
      
      if (user != null) {
        // Kullanıcı ID'sini ayarla
        userId.value = user.id;
        print('Kullanıcı yüklendi: ${user.fullName}, ID: ${user.id}');
        
        // Şimdi rozetleri yükle
        await loadUserBadges();
      } else {
        errorMessage = error ?? 'Kullanıcı bilgileri alınamadı';
        _isLoading = false;
        update();
      }
    } catch (e) {
      print('Kullanıcı bilgileri yüklenirken hata: $e');
      errorMessage = 'Oturum bilgileri yüklenirken hata oluştu: $e';
      _isLoading = false;
      update();
    }
  }
  
  Future<void> loadUserBadges() async {
    if (userId.value <= 0) {
      // Geçerli bir kullanıcı ID'si yoksa, önce kullanıcı bilgilerini yükle
      await _loadCurrentUser();
      return;
    }
    
    _isLoading = true;
    errorMessage = null;
    update();
    
    try {
      print('Kullanıcı rozetlerini yükleme başladı');
      print('Kullanıcı ID: ${userId.value}');
      
      // API istek sonucu
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      
      print('Token: ${token != null ? 'var' : 'yok'}');
      
      final (badgesData, error) = await userBadgeService.getUserBadges(userId.value, token);
      
      if (badgesData != null) {
        print('${badgesData.length} kullanıcı rozeti yüklendi');
        if (badgesData.isEmpty) {
          // Rozet yok ama hata da yok - boş liste döndü
          print('Kullanıcının rozeti bulunmuyor, normale çevriliyor');
          userBadges.clear();
          errorMessage = null;
        } else {
          // Rozetler başarıyla yüklendi
          userBadges.value = badgesData;
          
          // Rozet detaylarını kontrol et, eğer eksikler varsa ayrıca getir
          await getBadgeDetails(badgesData);
          
          // Kategorileri topla
          _collectCategories();
          
          errorMessage = null;
        }
      } else if (error != null) {
        print('Kullanıcı rozetlerini yükleme hatası: $error');
        errorMessage = error;
      } else {
        print('API yanıtı boş ve hata bilgisi yok');
        errorMessage = null;
        userBadges.clear();
      }
    } catch (e) {
      print('Kullanıcı rozetlerini yüklerken beklenmeyen hata: $e');
      errorMessage = 'Rozetler yüklenirken bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      update();
    }
  }
  
  // Rozet detaylarını almak için yardımcı metod
  Future<void> getBadgeDetails(List<UserBadgeModel> userBadges) async {
    // Badge id'lerini topla
    final badgeIds = <int>[];
    final badgesWithoutDetails = <UserBadgeModel>[];
    
    print("=== Badge Details Matching Process ===");
    // Önce mevcut rozet durumunu logla
    for (final userBadge in userBadges) {
      print("UserBadge ID: ${userBadge.id}, Badge ID: ${userBadge.badgeId}, Has Badge: ${userBadge.badge != null}");
      
      // Rozeti olmayan kullanıcı rozetlerini topla
      if (userBadge.badge == null && userBadge.badgeId > 0) {
        badgeIds.add(userBadge.badgeId);
        badgesWithoutDetails.add(userBadge);
      }
    }
    
    if (badgeIds.isEmpty) {
      print("Tüm rozet detayları mevcut, ek detay getirmeye gerek yok");
      return;
    }
    
    print("${badgeIds.length} rozet detayı alınacak: $badgeIds");
    
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      
      final details = await userBadgeService.getBadgeDetails(badgeIds, token);
      
      if (details.isNotEmpty) {
        print("${details.length} rozet detayı API'den alındı");
        badgeDetails.value = details;
        
        // Rozet ID'leri ile eşleştirme haritası oluştur
        final detailsMap = {for (var badge in details) badge.id ?? 0: badge};
        print("Badge details map: ${detailsMap.keys}");
        
        // Kullanıcı rozeti listesini güncelle
        final updatedUserBadges = <UserBadgeModel>[];
        
        for (int i = 0; i < userBadges.length; i++) {
          final userBadge = userBadges[i];
          
          // Rozet detayı yoksa ve badgeId bir detayla eşleşiyorsa güncelle
          if (userBadge.badge == null && 
              userBadge.badgeId > 0 && 
              detailsMap.containsKey(userBadge.badgeId)) {
            
            print("Badge ID ${userBadge.badgeId} için detay bulundu");
            // Yeni nesne oluştur
            final updatedBadge = UserBadgeModel(
              id: userBadge.id,
              userId: userBadge.userId,
              badgeId: userBadge.badgeId,
              earnedDate: userBadge.earnedDate,
              badge: detailsMap[userBadge.badgeId],
            );
            
            updatedUserBadges.add(updatedBadge);
          } else {
            if (userBadge.badge == null && userBadge.badgeId > 0) {
              print("Badge ID ${userBadge.badgeId} için detay bulunamadı");
              
              // Detayı bulunamayan rozet için varsayılan
              final fallbackBadge = BadgeModel(
                id: userBadge.badgeId,
                name: 'Rozet #${userBadge.badgeId}',
                description: 'Bu rozet için bilgiler şu anda alınamıyor.',
                imageUrl: 'https://cdn-icons-png.flaticon.com/512/1053/1053367.png',
              );
              
              // Fallback badge ile güncelle
              final updatedBadge = UserBadgeModel(
                id: userBadge.id,
                userId: userBadge.userId,
                badgeId: userBadge.badgeId,
                earnedDate: userBadge.earnedDate,
                badge: fallbackBadge,
              );
              
              updatedUserBadges.add(updatedBadge);
            } else {
              // Zaten rozet detayı var veya badgeId geçersiz
              updatedUserBadges.add(userBadge);
            }
          }
        }
        
        // Güncellenmiş listeyi ata
        userBadges.clear();
        userBadges.addAll(updatedUserBadges);
        update();
        
        // Kategorileri güncelle
        _collectCategories();
      } else {
        print("API'den rozet detayı alınamadı");
        _createFallbackBadges(userBadges);
      }
    } catch (e) {
      print('Rozet detaylarını alırken hata: $e');
      _createFallbackBadges(userBadges);
    }
  }
  
  // Fallback rozet detayları oluştur
  void _createFallbackBadges(List<UserBadgeModel> userBadges) {
    print("Fallback rozetler oluşturuluyor...");
    final updatedUserBadges = <UserBadgeModel>[];
    
    for (final userBadge in userBadges) {
      if (userBadge.badge == null && userBadge.badgeId > 0) {
        // Bu rozet için fallback detay oluştur
        final fallbackBadge = BadgeModel(
          id: userBadge.badgeId,
          name: 'Rozet #${userBadge.badgeId}',
          description: 'Bu rozet için bilgiler şu anda alınamıyor.',
          imageUrl: 'https://cdn-icons-png.flaticon.com/512/1053/1053367.png',
        );
        
        updatedUserBadges.add(UserBadgeModel(
          id: userBadge.id,
          userId: userBadge.userId,
          badgeId: userBadge.badgeId,
          earnedDate: userBadge.earnedDate,
          badge: fallbackBadge,
        ));
      } else {
        updatedUserBadges.add(userBadge);
      }
    }
    
    userBadges.clear();
    userBadges.addAll(updatedUserBadges);
    update();
    
    // Kategorileri güncelle
    _collectCategories();
  }
  
  // Kategorileri topla
  void _collectCategories() {
    final categorySet = <String>{};
    
    for (final userBadge in userBadges) {
      if (userBadge.badge != null && 
          userBadge.badge!.category != null && 
          userBadge.badge!.category!.isNotEmpty) {
        categorySet.add(userBadge.badge!.category!);
      }
    }
    
    categories.value = categorySet.toList()..sort();
  }
  
  // Bir rozet eklemek için
  Future<void> assignBadge(int badgeId) async {
    try {
      _isLoading = true;
      errorMessage = null;
      update();
      
      print('Rozet atama başladı - Rozet ID: $badgeId');
      
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        errorMessage = 'Oturum bilginiz bulunamadı. Lütfen tekrar giriş yapın.';
        update();
        return;
      }
      
      print('Token: var');
      
      final (success, message) = await userBadgeService.assignBadge(badgeId, token);
      
      if (success) {
        print('Rozet başarıyla atandı');
        // Başarı mesajı göster
        Get.snackbar(
          'Başarılı', 
          'Rozet başarıyla eklendi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
        // Listeyi yenile
        await loadUserBadges();
      } else {
        print('Rozet atama hatası: $message');
        errorMessage = message;
        // Hata mesajı göster
        Get.snackbar(
          'Hata', 
          message ?? 'Rozet eklenirken bir sorun oluştu',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
        update();
      }
    } catch (e) {
      print('Rozet atarken beklenmeyen hata: $e');
      errorMessage = 'Rozet atanırken bir hata oluştu: $e';
      // Hata mesajı göster
      Get.snackbar(
        'Hata', 
        'Rozet eklenirken beklenmeyen bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      update();
    } finally {
      _isLoading = false;
      update();
    }
  }
  
  Future<void> onRefresh() async {
    await loadUserBadges();
  }
  
  void onBadgeTapped(UserBadgeModel userBadge) {
    // Rozet detayına git
    if (userBadge.badge != null) {
      Get.toNamed('/badge_details', arguments: userBadge.badge);
    }
  }
  
  void filterByCategory(String category) {
    selectedCategory.value = category;
  }
  
  void clearCategoryFilter() {
    selectedCategory.value = '';
  }
  
  List<UserBadgeModel> get filteredBadges {
    if (selectedCategory.value.isEmpty) {
      return userBadges;
    }
    return userBadges.where((userBadge) => 
      userBadge.badge != null && 
      userBadge.badge!.category == selectedCategory.value).toList();
  }
} 