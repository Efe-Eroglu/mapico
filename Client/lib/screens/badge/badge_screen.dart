import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'badge_controller.dart';
import 'package:mapico/models/badge_model.dart';

class BadgeScreen extends GetView<BadgeController> {
  const BadgeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rozetler'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/my_badges'),
            tooltip: 'Rozetlerim',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadBadges,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: GetBuilder<BadgeController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Rozetler yükleniyor...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Test modu banner
              if (controller.isTestMode)
                Container(
                  width: double.infinity,
                  color: Colors.amber.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade800, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.usingFallback
                              ? 'Test modunda çalışıyor (API yanıtı düzgün işlenemedi)'
                              : 'Test modunda çalışıyor (Token kullanılmıyor)',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Kategori filtreleri
              Obx(() {
                if (controller.categories.isNotEmpty) {
                  return Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('Tümü'),
                            selected: controller.selectedCategory.value.isEmpty,
                            onSelected: (_) => controller.clearCategoryFilter(),
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue.shade800,
                          ),
                        ),
                        ...controller.categories.map((category) => 
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: controller.selectedCategory.value == category,
                              onSelected: (_) => controller.filterByCategory(category),
                              backgroundColor: Colors.grey.shade200,
                              selectedColor: Colors.blue.shade100,
                              checkmarkColor: Colors.blue.shade800,
                            ),
                          )
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              
              // Ana içerik
              Expanded(
                child: Obx(() {
                  if (controller.badges.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.military_tech,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage != null 
                                ? 'Hata Oluştu' 
                                : 'Rozet bulunamadı',
                            style: TextStyle(
                              fontSize: 18,
                              color: controller.errorMessage != null 
                                  ? Colors.red.shade700
                                  : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (controller.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                controller.errorMessage!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            Text(
                              'Daha sonra tekrar kontrol edin',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: controller.loadBadges,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Yenile'),
                          ),
                          TextButton(
                            onPressed: controller.testConnection,
                            child: const Text('API Bağlantısını Test Et'),
                          ),
                          TextButton(
                            onPressed: controller.createTestBadges,
                            child: const Text('Test Rozetlerini Göster'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filtrelenmiş rozet listesi
                  final filteredList = controller.filteredBadges;
                  
                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_list_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bu kategoride rozet bulunamadı',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: controller.clearCategoryFilter,
                            child: const Text('Filtreyi Temizle'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.onRefresh,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final badge = filteredList[index];
                        return _buildBadgeCard(context, badge);
                      },
                    ),
                  );
                }),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildBadgeCard(BuildContext context, BadgeModel badge) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => controller.onBadgeTapped(badge),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge image or icon
              Expanded(
                flex: 3,
                child: badge.imageUrl.isNotEmpty
                    ? Image.network(
                        badge.imageUrl,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.military_tech,
                            size: 64,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.military_tech,
                          size: 64,
                          color: Colors.amber.shade800,
                        ),
                      ),
              ),
              
              const SizedBox(height: 12),
              
              // Badge title
              Text(
                badge.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 4),
              
              // Badge description
              Expanded(
                flex: 2,
                child: Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Badge category & points
              if (badge.category != null || badge.pointValue != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badge.pointValue != null) ...[
                        Icon(
                          Icons.stars,
                          size: 14,
                          color: Colors.amber.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${badge.pointValue} Puan',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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