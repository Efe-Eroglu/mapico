import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import 'package:mapico/models/flight_model.dart';
import 'package:mapico/services/flight_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FlightController extends BaseController {
  final flights = <FlightModel>[].obs;
  bool _isLoading = false;
  String? errorMessage;
  bool _isTestMode = false;

  bool get isLoading => _isLoading;
  bool get isTestMode => _isTestMode;
  
  final flightService = FlightService();
  
  @override
  void onInit() {
    super.onInit();
    loadFlights();
  }
  
  Future<void> loadFlights() async {
    _isLoading = true;
    errorMessage = null;
    update();
    
    try {
      print('Uçuşları yükleme başladı');
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      
      if (token != null) {
        print('Token bulundu: ${token.substring(0, 10)}...');
        final (flightsData, error) = await flightService.getAllFlights(token);
        
        if (flightsData != null) {
          print('${flightsData.length} uçuş yüklendi');
          flights.value = flightsData;
          _isTestMode = false;
        } else if (error != null) {
          print('Uçuşları yükleme hatası: $error');
          errorMessage = error;
          showError(error);
          
          // Token ile çalışmadıysa, token olmadan deneyelim (test)
          await loadFlightsWithoutToken();
        }
      } else {
        print('Token bulunamadı!');
        errorMessage = 'Oturum bilgileriniz bulunamadı. Test modunda devam ediliyor...';
        showError('Oturum bilgileriniz bulunamadı, lütfen tekrar giriş yapın');
        
        // Token yoksa tokenless modda deneyelim
        await loadFlightsWithoutToken();
      }
    } catch (e) {
      print('Uçuşları yüklerken beklenmeyen hata: $e');
      errorMessage = 'Uçuşlar yüklenirken bir hata oluştu: $e';
      showError('Uçuşlar yüklenirken bir hata oluştu: $e');
      
      // Hata durumunda token olmadan deneyelim
      await loadFlightsWithoutToken();
    } finally {
      _isLoading = false;
      update();
    }
  }
  
  // Token olmadan uçuşları yükleme (test modu)
  Future<void> loadFlightsWithoutToken() async {
    try {
      print('Token olmadan uçuşları yükleme deneniyor (TEST MODU)');
      final (flightsData, error) = await flightService.getAllFlights();
      
      if (flightsData != null) {
        print('TEST: ${flightsData.length} uçuş yüklendi');
        flights.value = flightsData;
        _isTestMode = true;
        errorMessage = 'Test modunda çalışıyor (Token kullanılmıyor)';
        update();
      } else if (error != null) {
        print('TEST hatası: $error');
        // Test modu başarısız, API bağlantı testi yap
        testConnection();
      }
    } catch (e) {
      print('TEST modu hatası: $e');
    }
  }
  
  // API bağlantı testi
  Future<void> testConnection() async {
    try {
      final result = await flightService.testConnection();
      print('Bağlantı testi sonucu: $result');
      errorMessage = 'API Testi: $result';
      update();
    } catch (e) {
      print('Bağlantı testi hatası: $e');
    }
  }
  
  Future<void> onRefresh() async {
    await loadFlights();
  }
  
  void onFlightTapped(FlightModel flight) {
    Get.toNamed('/flight_details', arguments: flight);
  }
}

extension on bool {
  set value(bool value) {}
} 