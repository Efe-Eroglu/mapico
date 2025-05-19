import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'leaderboard_controller.dart';

class LeaderboardScreen extends GetView<LeaderboardController> {
  const LeaderboardScreen({Key? key}) : super(key: key);

  String _calculateDuration(String startTime, String endTime) {
    try {
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);
      final difference = end.difference(start);
      return '${difference.inMinutes} dakika';
    } catch (e) {
      return 'Süre hesaplanamadı';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skor Tablosu'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchLeaderboardData(),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal game selector
            if (controller.games.isNotEmpty) ...[
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: controller.games.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final game = controller.games[index];
                    final isSelected = controller.selectedGameId.value == game['id'];
                    return ChoiceChip(
                      label: Text(game['name'] ?? 'Oyun'),
                      selected: isSelected,
                      onSelected: (_) => controller.selectGame(game['id']),
                      selectedColor: Colors.blue.shade700,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
            ],
            // Leaderboard table (filtered by selected game)
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.leaderboardData.isEmpty
                      ? const Center(child: Text('Veri yok'))
                      : ListView(
                          children: [
                            // Top Scorer Highlight
                            if (controller.leaderboardData.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).primaryColor,
                                          Theme.of(context).primaryColor.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'En Yüksek Skor',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                controller.leaderboardData[0]['user_name'] ?? 'İsimsiz Kullanıcı',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${controller.leaderboardData[0]['score'] ?? 0}',
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            // Score Table
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      // Table Header
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            SizedBox(width: 50, child: Text('Sıra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                            Expanded(child: Text('Kullanıcı', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                            SizedBox(width: 100, child: Text('Skor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                            SizedBox(width: 100, child: Text('Süre', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                          ],
                                        ),
                                      ),
                                      // Table Body
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: controller.leaderboardData.length,
                                        itemBuilder: (context, index) {
                                          final item = controller.leaderboardData[index];
                                          final isTopThree = index < 3;
                                          
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: isTopThree 
                                                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                                                  : index.isEven 
                                                      ? Colors.grey.shade50 
                                                      : Colors.white,
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey.shade200,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              child: Row(
                                                children: [
                                                  // Rank
                                                  SizedBox(
                                                    width: 50,
                                                    child: Row(
                                                      children: [
                                                        if (isTopThree)
                                                          Icon(
                                                            index == 0
                                                                ? Icons.emoji_events
                                                                : index == 1
                                                                    ? Icons.workspace_premium
                                                                    : Icons.star,
                                                            color: Theme.of(context).primaryColor,
                                                            size: 20,
                                                          ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          '${index + 1}',
                                                          style: TextStyle(
                                                            fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
                                                            color: isTopThree ? Theme.of(context).primaryColor : Colors.black87,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Username
                                                  Expanded(
                                                    child: Text(
                                                      item['user_name'] ?? 'İsimsiz Kullanıcı',
                                                      style: TextStyle(
                                                        fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
                                                        color: isTopThree ? Theme.of(context).primaryColor : Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                  // Score
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      '${item['score'] ?? 0}',
                                                      style: TextStyle(
                                                        fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
                                                        color: isTopThree ? Theme.of(context).primaryColor : Colors.black87,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  // Duration
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      _calculateDuration(
                                                        item['started_at'] ?? '',
                                                        item['ended_at'] ?? '',
                                                      ),
                                                      style: TextStyle(
                                                        color: Colors.grey.shade600,
                                                        fontSize: 12,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
          ],
        );
      }),
    );
  }
} 