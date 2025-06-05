import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import 'package:mapico/models/flight_model.dart';
import 'package:mapico/services/flight_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FlightController extends BaseController {
  final flights = <FlightModel>[].obs;
  final flightStops = <int, List<dynamic>>{}.obs;
  final badgeDetails = <int, dynamic>{}.obs;
  String? errorMessage;
  bool _isTestMode = false;

  bool get isTestMode => _isTestMode;
  
  final flightService = FlightService();
  // API base URL
  final String baseUrl = dotenv.env['API_BASE_URL']!;
  
  @override
  void onInit() {
    super.onInit();
    fetchFlights();
  }
  
  Future<void> fetchBadgeDetails(int badgeId) async {
    if (badgeDetails.containsKey(badgeId)) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/badges/$badgeId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        badgeDetails[badgeId] = data;
      }
    } catch (e) {
      print('Error fetching badge details: $e');
    }
  }

  Future<void> fetchFlightStops() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/flight_stops/all'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Group stops by flight_id
        final Map<int, List<dynamic>> groupedStops = {};
        for (var stop in data) {
          final flightId = stop['flight_id'];
          if (!groupedStops.containsKey(flightId)) {
            groupedStops[flightId] = [];
          }
          groupedStops[flightId]!.add(stop);
        }

        // Sort stops by order within each flight
        groupedStops.forEach((flightId, stops) {
          stops.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
        });

        flightStops.value = groupedStops;

        // Fetch badge details for all stops with badges
        for (var stops in groupedStops.values) {
          for (var stop in stops) {
            if (stop['reward_badge'] != null) {
              await fetchBadgeDetails(stop['reward_badge']);
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching flight stops: $e');
    }
  }

  Future<void> fetchFlights() async {
    try {
      setLoading(true);
      errorMessage = null;
      update();
      
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
          await fetchFlightStops();
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
      setLoading(false);
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
        await fetchFlightStops();
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
    await fetchFlights();
  }
  
  void onFlightTapped(FlightModel flight) {
    try {
      print('Navigating to flight details for flight: ${flight.id} - ${flight.title}');
      Get.toNamed('/flight_details', arguments: flight);
    } catch (e) {
      print('Error navigating to flight details: $e');
      Get.snackbar(
        'Hata',
        'Uçuş detayları açılırken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

extension on bool {
  set value(bool value) {}
} 