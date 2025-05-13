import 'package:get/get.dart';
import '../../core/base/base_controller.dart';

class HomeController extends BaseController {
  // Kullanıcı bilgileri
  final userName = 'Misafir'.obs;
  final userRole = 'Kullanıcı'.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setLoading(true);
    try {
      // TODO: Kullanıcı verilerini yükle
      await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş gecikme
      userName.value = 'Ahmet Yılmaz';
      userRole.value = 'Premium Üye';
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