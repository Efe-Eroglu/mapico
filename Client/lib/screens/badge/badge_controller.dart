import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import 'package:mapico/models/badge_model.dart';
import 'package:mapico/services/badge_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BadgeController extends BaseController {
  final badges = <BadgeModel>[].obs;
  bool _isLoading = false;
  String? errorMessage;
  bool _isTestMode = false;
  bool _manualTestCalled = false;
  bool _fallbackCreated = false;

  bool get isLoading => _isLoading;
  bool get isTestMode => _isTestMode;
  bool get usingFallback => _fallbackCreated;
  
  final badgeService = BadgeService();
  
  // Kategori filtresi
  final selectedCategory = RxString('');
  final categories = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadBadges();
  }
  
  Future<void> loadBadges() async {
    _isLoading = true;
    errorMessage = null;
    _fallbackCreated = false;
    update();
    
    try {
      print('Rozetleri yükleme başladı');
      
      // API istek sonucu
      final (badgesData, error) = await badgeService.getAllBadges();
      
      if (badgesData != null && badgesData.isNotEmpty) {
        print('${badgesData.length} rozet yüklendi');
        badges.value = badgesData;
        _isTestMode = false;
        
        // Kategorileri topla
        final categorySet = <String>{};
        for (final badge in badgesData) {
          if (badge.category != null && badge.category!.isNotEmpty) {
            categorySet.add(badge.category!);
          }
        }
        categories.value = categorySet.toList()..sort();
        
        // API yanıtı analizi
        if (badgesData.length == 1 && badgesData[0].id == 999) {
          _fallbackCreated = true;
          errorMessage = 'API yanıtı işlenemedi, fallback rozet gösteriliyor';
          _isTestMode = true;
        } else {
          _isTestMode = false;
          errorMessage = null;
        }
      } else if (error != null) {
        print('Rozetleri yükleme hatası: $error');
        errorMessage = error;
        createTestBadges();
      } else {
        print('API yanıtı boş ve hata bilgisi yok');
        errorMessage = 'API yanıtı alınamadı';
        createTestBadges();
      }
    } catch (e) {
      print('Rozetleri yüklerken beklenmeyen hata: $e');
      errorMessage = 'Rozetler yüklenirken bir hata oluştu: $e';
      createTestBadges();
    } finally {
      _isLoading = false;
      update();
    }
  }
  
  int min(int a, int b) => a < b ? a : b;
  
  // Token olmadan rozetleri yükleme (test modu)
  Future<void> loadBadgesWithoutToken() async {
    try {
      print('Token olmadan rozetleri yükleme deneniyor');
      
      try {
        final (badgesData, error) = await badgeService.getAllBadges();
        
        if (badgesData != null && badgesData.isNotEmpty) {
          print('TEST: ${badgesData.length} rozet yüklendi');
          badges.value = badgesData;
          _isTestMode = true;
          
          // Test için oluşturulmuş rozet olup olmadığını kontrol et
          if (badgesData.length == 1 && badgesData[0].id == 999) {
            _fallbackCreated = true;
            errorMessage = 'API yanıtı işlenemedi, fallback rozet gösteriliyor';
          } else {
            errorMessage = null;
          }
          
          // Kategorileri topla
          final categorySet = <String>{};
          for (final badge in badgesData) {
            if (badge.category != null && badge.category!.isNotEmpty) {
              categorySet.add(badge.category!);
            }
          }
          categories.value = categorySet.toList()..sort();
          
          update();
          return;
        } else if (error != null) {
          print('TEST hatası: $error');
          errorMessage = error;
        } else {
          // Hem badgesData hem error null ise
          print('TEST API yanıtı boş ve hata bilgisi yok');
          errorMessage = 'API yanıtı alınamadı';
        }
      } catch (e) {
        print('Token olmadan API isteğinde hata: $e');
        errorMessage = 'API bağlantı hatası: $e';
      }
    } catch (e) {
      print('TEST modu hatası: $e');
      errorMessage = 'API bağlantı hatası: $e';
    }
    update();
  }
  
  // API bağlantı testi
  Future<void> testConnection() async {
    try {
      _isLoading = true;
      update();
      
      final result = await badgeService.testConnection();
      print('Bağlantı testi sonucu: $result');
      errorMessage = 'API Testi: $result';
      
      // Test moduna geç
      if (badges.isEmpty && !_fallbackCreated) {
        createTestBadges();
      }
      
    } catch (e) {
      print('Bağlantı testi hatası: $e');
      errorMessage = 'Bağlantı testi hatası: $e';
      
      // Test moduna geç
      if (badges.isEmpty && !_fallbackCreated) {
        createTestBadges();
      }
    } finally {
      _isLoading = false;
      update();
    }
  }
  
  // Badge oluşturma (API yanıtı düzgün olmadığında test için)
  void createTestBadges() {
    final testBadges = [
      BadgeModel(
        id: 1, 
        name: 'Altın Rozet', 
        description: 'Bu rozet en yüksek puanı alan kullanıcılara verilir.',
        imageUrl: 'https://png.pngtree.com/png-vector/20220731/ourmid/pngtree-3rd-place-bronze-medal-png-image_6091788.png',
        category: 'Başarı',
        pointValue: 100,
      ),
      BadgeModel(
        id: 2, 
        name: 'Gezgin', 
        description: 'Birçok farklı lokasyonu ziyaret eden kullanıcılara verilir.',
        imageUrl: 'https://png.pngtree.com/png-vector/20220731/ourmid/pngtree-3rd-place-bronze-medal-png-image_6091788.png',
        category: 'Seyahat',
        pointValue: 50,
      ),
    ];
    
    badges.value = testBadges;
    
    // Kategorileri topla
    final categorySet = <String>{'Başarı', 'Seyahat'};
    categories.value = categorySet.toList()..sort();
    
    _isTestMode = true;
    _fallbackCreated = true;
    errorMessage = 'Test verileri gösteriliyor';
    update();
  }
  
  Future<void> onRefresh() async {
    await loadBadges();
  }
  
  void onBadgeTapped(BadgeModel badge) {
    Get.toNamed('/badge_details', arguments: badge);
  }
  
  void filterByCategory(String category) {
    selectedCategory.value = category;
  }
  
  void clearCategoryFilter() {
    selectedCategory.value = '';
  }
  
  List<BadgeModel> get filteredBadges {
    if (selectedCategory.value.isEmpty) {
      return badges;
    }
    return badges.where((badge) => badge.category == selectedCategory.value).toList();
  }
} 