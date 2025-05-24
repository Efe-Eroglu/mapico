import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import 'package:mapico/models/user_model.dart';
import 'package:mapico/models/avatar_model.dart';
import 'package:mapico/models/game_model.dart';
import 'package:mapico/services/auth_service.dart';
import 'package:mapico/services/game_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../app/routes/app_routes.dart';

class HomeController extends BaseController {
  // Kullanıcı bilgileri
  final userName = 'Misafir'.obs;
  final userRole = 'Kullanıcı'.obs;
  final user = Rxn<UserModel>();
  final avatar = Rxn<AvatarModel>();

  // Oyun bilgileri
  final games = <GameModel>[].obs;
  final isGamesLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadGames();
  }

  Future<void> loadUserData() async {
    setLoading(true);
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        final authService = AuthService();
        final (userData, userError) = await authService.getCurrentUser(token);
        final (avatarData, avatarError) =
            await authService.getUserAvatar(token);
        if (userData != null) {
          user.value = userData;
          userName.value = userData.fullName;
        }
        if (avatarData != null) {
          avatar.value = avatarData;
        }
        // userRole örnek: Premium Üye, Normal Kullanıcı vs. (gerekirse güncellenebilir)
      }
    } catch (e) {
      showError('Kullanıcı bilgileri yüklenemedi');
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadGames() async {
    isGamesLoading.value = true;
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        final gameService = GameService();
        final (gamesData, gamesError) = await gameService.getAllGames(token);
        if (gamesData != null) {
          games.value = gamesData;
        } else if (gamesError != null) {
          showError(gamesError);
        }
      }
    } catch (e) {
      showError('Oyunlar yüklenemedi');
    } finally {
      isGamesLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await loadUserData();
    await loadGames();
  }

  void onNotificationPressed() {
    Get.toNamed('/notifications');
  }

  void onProfilePressed() {
    Get.toNamed('/profile');
  }

  void onAddPressed() {
    Get.toNamed('/create');
  }

  void onGameTapped(GameModel game) {
    // Oyun id'sine göre ilgili detay sayfasına yönlendir
    switch (game.id) {
      case 1:
        Get.toNamed(AppRoutes.GAME1_DETAIL, arguments: game);
        break;
      case 3:
        Get.toNamed(AppRoutes.GAME2_DETAIL, arguments: game);
        break;
      case 4:
        Get.toNamed(AppRoutes.GAME3_DETAIL, arguments: game);
        break;
      default:
        Get.toNamed(
            AppRoutes.GAME_DETAIL.replaceFirst(':id', game.id.toString()),
            arguments: game);
    }
  }
}
