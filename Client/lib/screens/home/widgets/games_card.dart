import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import 'package:mapico/models/game_model.dart';

class GamesCard extends GetView<HomeController> {
  const GamesCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Oyunlar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.games),
              label: const Text('Tümünü Gör'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isGamesLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (controller.games.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_esports_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz oyun bulunmuyor',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.games.length,
              itemBuilder: (context, index) {
                final game = controller.games[index];
                return _buildGameCard(context, game, index);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGameCard(BuildContext context, GameModel game, int index) {
    // Her oyun için farklı bir renk seti kullan
    final List<List<Color>> colorSets = [
      [const Color(0xFF4CAF50), const Color(0xFF2E7D32)], // Yeşil
      [const Color(0xFF2196F3), const Color(0xFF1565C0)], // Mavi
      [const Color(0xFFFF9800), const Color(0xFFEF6C00)], // Turuncu
      [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)], // Mor
      [const Color(0xFFF44336), const Color(0xFFB71C1C)], // Kırmızı
    ];
    
    // Her oyun için bir ikon seç
    final List<IconData> icons = [
      Icons.sports_esports,
      Icons.flight,
      Icons.public,
      Icons.extension,
      Icons.psychology,
    ];
    
    // Renk ve ikonları döngüsel olarak kullan
    final colors = colorSets[index % colorSets.length];
    final icon = icons[index % icons.length];
    
    return GestureDetector(
      onTap: () => controller.onGameTapped(game),
      child: Container(
        width: 180,
        margin: EdgeInsets.only(
          right: 16, 
          top: index.isEven ? 0 : 10, // Farklı yükseklikler için
          bottom: index.isEven ? 10 : 0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.2),
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
                    colors: colors,
                  ),
                ),
              ),
              
              // Game details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Game title
                    Text(
                      game.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Game description
                    Text(
                      game.description ?? 'Açıklama yok',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Play button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Oyna',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.play_arrow,
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
              
              // Game code (if available)
              if (game.code != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Kod: ${game.code}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 