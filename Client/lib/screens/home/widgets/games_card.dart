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
        Text(
          'Oyunlar',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isGamesLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (controller.games.isEmpty) {
            return const Center(
              child: Text('Henüz oyun bulunmuyor'),
            );
          }
          
          return SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.games.length,
              itemBuilder: (context, index) {
                final game = controller.games[index];
                return _buildGameCard(context, game);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGameCard(BuildContext context, GameModel game) {
    return GestureDetector(
      onTap: () => controller.onGameTapped(game),
      child: SizedBox(
        width: 160,
        child: Card(
          elevation: 3,
          margin: const EdgeInsets.only(right: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game icon
                const Icon(
                  Icons.games,
                  size: 48,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                // Game title
                Text(
                  game.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Game description
                Text(
                  game.description ?? 'Açıklama yok',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 