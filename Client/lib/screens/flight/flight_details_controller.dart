import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapico/models/flight_model.dart';

class FlightDetailsController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<dynamic> flightStops = <dynamic>[].obs;
  final Rx<FlightModel?> flight = Rx<FlightModel?>(null);
  final RxMap<int, dynamic> badgeDetails = <int, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final flightData = Get.arguments as FlightModel;
    flight.value = flightData;
    fetchFlightDetails(flightData.id);
  }

  Future<void> fetchBadgeDetails(int badgeId) async {
    if (badgeDetails.containsKey(badgeId)) return;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/v1/badges/$badgeId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        badgeDetails[badgeId] = data;
      }
    } catch (e) {
      print('Error fetching badge details: $e');
    }
  }

  Future<void> fetchFlightDetails(int flightId) async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/v1/flight_stops/by_flight/$flightId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Sort stops by order
        final sortedData = List.from(data)..sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
        flightStops.value = sortedData;

        // Fetch badge details for stops with badges
        for (var stop in sortedData) {
          if (stop['reward_badge'] != null) {
            await fetchBadgeDetails(stop['reward_badge']);
          }
        }
      } else {
        Get.snackbar(
          'Hata',
          'Uçuş detayları yüklenirken bir hata oluştu',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error fetching flight details: $e');
      Get.snackbar(
        'Hata',
        'Bağlantı hatası oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 