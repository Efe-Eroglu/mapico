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
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.leaderboardData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Henüz skor bulunmuyor',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.fetchLeaderboardData(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yenile'),
                ),
              ],
            ),
          );
        }

        // Sort data by score in descending order
        final sortedData = List.from(controller.leaderboardData)
          ..sort((a, b) => (b['score'] ?? 0).compareTo(a['score'] ?? 0));

        return RefreshIndicator(
          onRefresh: controller.fetchLeaderboardData,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              children: [
                // Top Scorer Highlight
                if (sortedData.isNotEmpty) ...[
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
                                    sortedData[0]['user_name'] ?? 'İsimsiz Kullanıcı',
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
                                '${sortedData[0]['score'] ?? 0}',
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
                            itemCount: sortedData.length,
                            itemBuilder: (context, index) {
                              final item = sortedData[index];
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
        );
      }),
    );
  }
} 