import 'package:get/get.dart';
import '../../screens/home/home_binding.dart';
import '../../screens/home/home_view.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/register/register_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterScreen(),
    ),
  ];
}

