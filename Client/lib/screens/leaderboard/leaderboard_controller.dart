import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaderboardController extends GetxController {
  final RxList<dynamic> leaderboardData = <dynamic>[].obs;
  final RxBool isLoading = true.obs;
  final RxList<dynamic> games = <dynamic>[].obs;
  final RxInt selectedGameId = 0.obs;
  
  // API base URL
  final String baseUrl = 'http://10.0.2.2:8000';

  @override
  void onInit() {
    super.onInit();
    print('LeaderboardController initialized');
    fetchLeaderboardData();
    fetchGames();
  }

  Future<void> fetchLeaderboardData([int? gameId]) async {
    try {
      print('Fetching leaderboard data...');
      isLoading.value = true;
      final id = gameId ?? selectedGameId.value;
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/game_sessions/sorted_by_score/$id'),
      );
      print('Response status code: \\${response.statusCode}');
      print('Response body: \\${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded data: \\${data}');
        leaderboardData.value = data;
      } else {
        Get.snackbar(
          'Hata',
          'Veriler yüklenirken bir hata oluştu: \\${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error fetching data: \\${e}');
      Get.snackbar(
        'Hata',
        'Bağlantı hatası oluştu: \\${e}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGames() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/v1/games'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        games.value = data;
        if (games.isNotEmpty) {
          selectedGameId.value = games[0]['id'];
        }
      }
    } catch (e) {
      print('Oyunlar alınırken hata: $e');
    }
  }

  void selectGame(int gameId) {
    selectedGameId.value = gameId;
    fetchLeaderboardData(gameId);
  }
} 