import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapico/models/game_model.dart';

class GameDetailPage extends StatelessWidget {
  const GameDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // URL'den gelen id parametresi
    final String? gameId = Get.parameters['id'];

    // Oyun modeli argümanı
    final GameModel? game = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(game?.title ?? 'Oyun Detayı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: game == null
            ? Center(
                child: Text(
                  'Oyun bilgisi bulunamadı.\nID: $gameId',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    game.description ?? 'Açıklama yok',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  // İstersen oyun ile ilgili daha fazla detay ekleyebilirsin
                ],
              ),
      ),
    );
  }
}
