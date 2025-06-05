import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeaturedSection extends StatelessWidget {
  const FeaturedSection({Key? key}) : super(key: key);

  // Öne çıkan öğeleri temsil eden model sınıfı
  final List<FeaturedItem> _featuredItems = const [
    FeaturedItem(
      title: 'Yeni Yemek Oyunu',
      description: 'Türk mutfağını keşfet!',
      backgroundColor: Color(0xFFFFA726),
      iconData: Icons.restaurant,
      iconColor: Colors.white,
      route: '/game3',
    ),
    FeaturedItem(
      title: 'Balon Patlatma',
      description: 'Hızlı ve eğlenceli',
      backgroundColor: Color(0xFF42A5F5),
      iconData: Icons.offline_bolt,
      iconColor: Colors.white,
      route: '/game1',
    ),
    FeaturedItem(
      title: 'Ülkeleri Tanı',
      description: 'Dünyayı keşfet',
      backgroundColor: Color(0xFF66BB6A),
      iconData: Icons.public,
      iconColor: Colors.white,
      route: '/game4',
    ),
    FeaturedItem(
      title: 'Premium Rozet',
      description: 'Yeni rozetler kazanın',
      backgroundColor: Color(0xFFAB47BC),
      iconData: Icons.military_tech,
      iconColor: Colors.white,
      route: '/badges',
    ),
    FeaturedItem(
      title: 'Sıralama',
      description: 'En yüksek puanlar',
      backgroundColor: Color(0xFFEF5350),
      iconData: Icons.leaderboard,
      iconColor: Colors.white,
      route: '/leaderboard',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Öne Çıkanlar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Tüm öne çıkanları göster
              },
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _featuredItems.length,
            itemBuilder: (context, index) {
              final item = _featuredItems[index];
              return _buildFeaturedCard(context, item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(BuildContext context, FeaturedItem item, int index) {
    return GestureDetector(
      onTap: () {
        if (item.route.isNotEmpty) {
          Get.toNamed(item.route);
        }
      },
      child: Container(
        width: 200,
        margin: EdgeInsets.only(
          right: 16,
          bottom: 8,
          top: index % 2 == 0 ? 10 : 0, // Farklı yükseklikler için
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: item.backgroundColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      item.backgroundColor,
                      item.backgroundColor.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon in a circular container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.iconData,
                        size: 36,
                        color: item.iconColor,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Title and description
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Action button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Keşfet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeaturedItem {
  final String title;
  final String description;
  final Color backgroundColor;
  final IconData iconData;
  final Color iconColor;
  final String route;

  const FeaturedItem({
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.iconData,
    required this.iconColor,
    this.route = '',
  });
} 