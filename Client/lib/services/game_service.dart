import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapico/models/game_model.dart';

class GameService {
  static const String _baseUrl = 'http://34.31.239.252:8000/api/v1';

  // Get all games
  Future<(List<GameModel>?, String?)> getAllGames(String token) async {
    final url = Uri.parse('$_baseUrl/games');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        final games = data.map((e) => GameModel.fromJson(e)).toList();
        return (games, null);
      } else {
        return (null, 'Oyun listesi alınamadı');
      }
    } else {
      String errorMsg = 'Oyun listesi alınamadı';
      try {
        final data = json.decode(response.body);
        if (data is Map && data['detail'] != null) {
          errorMsg = data['detail'].toString();
        }
      } catch (_) {}
      print('Get all games failed: ${response.statusCode} - ${response.body}');
      return (null, errorMsg);
    }
  }

  // Get a single game by ID
  Future<(GameModel?, String?)> getGame(String token, int gameId) async {
    final url = Uri.parse('$_baseUrl/games/$gameId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (GameModel.fromJson(data), null);
    } else {
      String errorMsg = 'Oyun bilgisi alınamadı';
      try {
        final data = json.decode(response.body);
        if (data is Map && data['detail'] != null) {
          errorMsg = data['detail'].toString();
        }
      } catch (_) {}
      print('Get game failed: ${response.statusCode} - ${response.body}');
      return (null, errorMsg);
    }
  }
}
