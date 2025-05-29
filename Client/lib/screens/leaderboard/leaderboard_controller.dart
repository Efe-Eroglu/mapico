import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LeaderboardController extends GetxController {
  final RxList<dynamic> leaderboardData = <dynamic>[].obs;
  final RxBool isLoading = true.obs;
  final RxList<dynamic> games = <dynamic>[].obs;
  final RxInt selectedGameId = 0.obs;

  // API base URL
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  @override
  void onInit() {
    super.onInit();
    print('LeaderboardController initialized');
    print('API BASE URL: $baseUrl');
    fetchGames();
  }

  Future<void> fetchLeaderboardData([int? gameId]) async {
    try {
      final id = gameId ?? selectedGameId.value;
      
      print('Fetching leaderboard data for game ID: $id');
      if (id <= 0) {
        print('Invalid game ID: $id, not fetching data');
        return;
      }
      
      isLoading.value = true;
      final url = '$baseUrl/game_sessions/sorted_by_score/$id';
      print('Request URL: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);
        print('Decoded data: $rawData');
        print('Number of records: ${rawData.length}');
        
        // Aggregate data by user_id
        final Map<int, Map<String, dynamic>> userScores = {};
        
        for (var item in rawData) {
          final userId = item['user_id'];
          final userName = item['user_name'];
          final score = item['score'] as int;
          
          if (!userScores.containsKey(userId)) {
            // Initialize new user entry
            userScores[userId] = {
              'user_id': userId,
              'user_name': userName,
              'score': 0,
              'game_count': 0,
              'best_session_id': null,
              'started_at': null,
              'ended_at': null
            };
          }
          
          // Add score to user's total
          userScores[userId]!['score'] += score;
          userScores[userId]!['game_count'] += 1;
          
          // Track the best session for time calculation
          if (userScores[userId]!['best_session_id'] == null || score > (userScores[userId]!['best_session_score'] ?? 0)) {
            userScores[userId]!['best_session_id'] = item['id'];
            userScores[userId]!['best_session_score'] = score;
            userScores[userId]!['started_at'] = item['started_at'];
            userScores[userId]!['ended_at'] = item['ended_at'];
          }
        }
        
        // Convert to list and sort by score
        final List<Map<String, dynamic>> aggregatedData = userScores.values.toList();
        aggregatedData.sort((a, b) => b['score'].compareTo(a['score']));
        
        print('Aggregated data: $aggregatedData');
        leaderboardData.value = aggregatedData;
      } else {
        print('Error response: ${response.reasonPhrase}');
        // Check if it's the specific "not found" error
        if (response.body.contains("Leaderboard not found")) {
          print('No leaderboard data exists for this game');
          leaderboardData.value = []; // Clear any existing data
          Get.snackbar(
            'Bilgi',
            'Bu oyun için henüz sıralama verisi bulunmuyor.',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Hata',
            'Veriler yüklenirken bir hata oluştu: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
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

  Future<void> fetchGames() async {
    try {
      print('Fetching games list');
      final url = '$baseUrl/games';
      print('Request URL: $url');
      
      final response = await http.get(Uri.parse(url));
      print('Games response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Games data: $data');
        games.value = data;
        if (games.isNotEmpty) {
          selectedGameId.value = games[0]['id'];
          print('Selected first game with ID: ${selectedGameId.value}');
          // Now fetch leaderboard data after we have a valid game ID
          fetchLeaderboardData(selectedGameId.value);
        } else {
          print('No games found in the response');
        }
      } else {
        print('Error fetching games: ${response.reasonPhrase}');
        Get.snackbar(
          'Hata',
          'Oyun verileri alınamadı: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Oyunlar alınırken hata: $e');
      Get.snackbar(
        'Hata',
        'Bağlantı hatası oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void selectGame(int gameId) {
    print('Game selected: $gameId');
    selectedGameId.value = gameId;
    fetchLeaderboardData(gameId);
  }
}
