import 'package:get/get.dart';
import 'badge_controller.dart';

class BadgeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BadgeController>(() => BadgeController());
  }
} 