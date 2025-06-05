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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hızlı Erişim',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.apps),
              label: const Text('Tümü'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _quickAccessCategories.length,
            itemBuilder: (context, index) {
              final category = _quickAccessCategories[index];
              return _buildActionItem(context, category);
            },
          ),
        ),
        const SizedBox(height: 24),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _popularActions.map((action) => 
            _buildActionChip(context, action)
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, QuickActionItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    item.color,
                    item.color.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, QuickActionItem action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(30),
      child: Chip(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        avatar: Icon(
          action.icon,
          size: 18,
          color: action.color,
        ),
        label: Text(
          action.title,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        side: BorderSide.none,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    );
  }

  // Ana kategoriler
  List<QuickActionItem> get _quickAccessCategories => [
        QuickActionItem(
          title: 'Oyunlar',
          icon: Icons.sports_esports,
          color: const Color(0xFF4CAF50),
          onTap: () => Get.toNamed('/game1'),
        ),
        QuickActionItem(
          title: 'Uçuşlar',
          icon: Icons.flight,
          color: const Color(0xFF2196F3),
          onTap: () => Get.toNamed('/flights'),
        ),
        QuickActionItem(
          title: 'Rozetler',
          icon: Icons.military_tech,
          color: const Color(0xFFFF9800),
          onTap: () => Get.toNamed('/badges'),
        ),
        QuickActionItem(
          title: 'Ekipman',
          icon: Icons.backpack,
          color: const Color(0xFF9C27B0),
          onTap: () => Get.toNamed('/equipment'),
        ),
        QuickActionItem(
          title: 'Sıralama',
          icon: Icons.leaderboard,
          color: const Color(0xFFF44336),
          onTap: () => Get.toNamed(AppRoutes.LEADERBOARD),
        ),
      ];

  // Popüler eylemler
  List<QuickActionItem> get _popularActions => [
        QuickActionItem(
          title: 'Profilim',
          icon: Icons.person_outline,
          color: const Color(0xFF607D8B),
          onTap: () => controller.onProfilePressed(),
        ),
        QuickActionItem(
          title: 'Bildirimler',
          icon: Icons.notifications_outlined,
          color: const Color(0xFFFF5722),
          onTap: () => controller.onNotificationPressed(),
        ),
        QuickActionItem(
          title: 'Ayarlar',
          icon: Icons.settings_outlined,
          color: const Color(0xFF795548),
          onTap: () => Get.toNamed('/settings'),
        ),
        QuickActionItem(
          title: 'Yeni Ekle',
          icon: Icons.add_circle_outline,
          color: const Color(0xFF009688),
          onTap: () => controller.onAddPressed(),
        ),
        QuickActionItem(
          title: 'Arkadaşlar',
          icon: Icons.people_outline,
          color: const Color(0xFF3F51B5),
          onTap: () {},
        ),
      ];
}

class QuickActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
} 