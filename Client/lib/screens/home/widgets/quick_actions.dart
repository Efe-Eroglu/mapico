import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import '../../../app/routes/app_routes.dart';

class QuickActions extends GetView<HomeController> {
  const QuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Erişim',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              context,
              'Yeni Ekle',
              Icons.add_circle,
              Colors.blue,
              () => controller.onAddPressed(),
            ),
            _buildActionCard(
              context,
              'Profilim',
              Icons.person,
              Colors.green,
              () => controller.onProfilePressed(),
            ),
            _buildActionCard(
              context,
              'Bildirimler',
              Icons.notifications,
              Colors.orange,
              () => controller.onNotificationPressed(),
            ),
            _buildActionCard(
              context,
              'Ayarlar',
              Icons.settings,
              Colors.purple,
              () => Get.toNamed('/settings'),
            ),
            _buildActionCard(
              context,
              'Ekipmanlar',
              Icons.construction,
              Colors.teal,
              () => Get.toNamed('/equipment'),
            ),
            _buildActionCard(
              context,
              'Uçuşlar',
              Icons.flight,
              Colors.deepOrange,
              () => Get.toNamed('/flights'),
            ),
            _buildActionCard(
              context,
              'Rozetler',
              Icons.military_tech,
              Colors.amber,
              () => Get.toNamed('/badges'),
            ),
            _buildActionCard(
              context,
              'Leaderboards',
              Icons.leaderboard,
              Colors.amber,
              () => Get.toNamed(AppRoutes.LEADERBOARD),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 