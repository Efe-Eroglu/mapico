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
import '../../screens/badge/badge_screen.dart';
import '../../screens/badge/badge_details_screen.dart';
import '../../screens/badge/badge_binding.dart';
import '../../screens/badge/my_badges_screen.dart';
import '../../screens/badge/my_badges_controller.dart';
import '../../screens/leaderboard/leaderboard_screen.dart';
import '../../screens/leaderboard/leaderboard_binding.dart';
import 'app_routes.dart';
import '../../screens/flight/flight_details_binding.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/settings/settings_controller.dart';

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
      binding: FlightDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.BADGES,
      page: () => const BadgeScreen(),
      binding: BadgeBinding(),
    ),
    GetPage(
      name: AppRoutes.BADGE_DETAILS,
      page: () => const BadgeDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.MY_BADGES,
      page: () => const MyBadgesScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MyBadgesController>(() => MyBadgesController());
      }),
    ),
    GetPage(
      name: AppRoutes.LEADERBOARD,
      page: () => const LeaderboardScreen(),
      binding: LeaderboardBinding(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),
  ];
}

