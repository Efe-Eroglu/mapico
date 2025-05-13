import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import 'package:mapico/models/user_model.dart';
import 'package:mapico/models/avatar_model.dart';
import 'package:mapico/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeController extends BaseController {
  // Kullanıcı bilgileri
  final userName = 'Misafir'.obs;
  final userRole = 'Kullanıcı'.obs;
  final user = Rxn<UserModel>();
  final avatar = Rxn<AvatarModel>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setLoading(true);
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        final authService = AuthService();
        final (userData, userError) = await authService.getCurrentUser(token);
        final (avatarData, avatarError) = await authService.getUserAvatar(token);
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

  Future<void> onRefresh() async {
    await loadUserData();
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
} 