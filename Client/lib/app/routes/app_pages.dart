import 'package:get/get.dart';
import '../../screens/home/home_binding.dart';
import '../../screens/home/home_view.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/register/register_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/equipment/equipment_screen.dart';
import '../../screens/equipment/my_equipment_screen.dart';
import '../../screens/flight/flight_screen.dart';
import '../../screens/flight/flight_details_screen.dart';
import '../../screens/flight/flight_binding.dart';
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
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.EQUIPMENT,
      page: () => const EquipmentScreen(),
    ),
    GetPage(
      name: AppRoutes.MY_EQUIPMENT,
      page: () => const MyEquipmentScreen(),
    ),
    GetPage(
      name: AppRoutes.FLIGHTS,
      page: () => const FlightScreen(),
      binding: FlightBinding(),
    ),
    GetPage(
      name: AppRoutes.FLIGHT_DETAILS,
      page: () => const FlightDetailsScreen(),
    ),
  ];
}

