import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaderboardController extends GetxController {
  final RxList<dynamic> leaderboardData = <dynamic>[].obs;
  final RxBool isLoading = true.obs;
  
  // API base URL
  final String baseUrl = 'http://10.0.2.2:8000';

  @override
  void onInit() {
    super.onInit();
    print('LeaderboardController initialized');
    fetchLeaderboardData();
  }

  Future<void> fetchLeaderboardData() async {
    try {
      print('Fetching leaderboard data...');
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/game_sessions/sorted_by_score/7'),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded data: $data');
        leaderboardData.value = data;
      } else {
        Get.snackbar(
          'Hata',
          'Veriler yüklenirken bir hata oluştu: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error fetching data: $e');
      Get.snackbar(
        'Hata',
        'Bağlantı hatası oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 