import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_badges_controller.dart';
import 'package:mapico/models/user_badge_model.dart';
import 'package:intl/intl.dart';

class MyBadgesScreen extends GetView<MyBadgesController> {
  const MyBadgesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rozetlerim'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadUserBadges,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: GetBuilder<MyBadgesController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Rozetleriniz yükleniyor...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
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
                  if (controller.userBadges.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            controller.errorMessage != null
                                ? Icons.error_outline
                                : Icons.emoji_events_outlined,
                            size: 80,
                            color: controller.errorMessage != null
                                ? Colors.red.shade300
                                : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage != null 
                                ? 'Hata Oluştu' 
                                : 'Henüz rozet kazanmadınız',
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
                              'Aktivitelere katılarak rozetler kazanabilirsiniz.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: controller.loadUserBadges,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Yenile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          
                          // Test rozeti ekleme butonu - normalde son kullanıcıya gösterilmeyecek
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Divider(height: 32),
                                const Text(
                                  'Test Rozetleri', 
                                  style: TextStyle(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey
                                  )
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => controller.assignBadge(1),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Rozet 1'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade100,
                                        foregroundColor: Colors.green.shade800
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton.icon(
                                      onPressed: () => controller.assignBadge(2),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Rozet 2'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade100,
                                        foregroundColor: Colors.blue.shade800
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                        final userBadge = filteredList[index];
                        return _buildUserBadgeCard(context, userBadge);
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

  Widget _buildUserBadgeCard(BuildContext context, UserBadgeModel userBadge) {
    final badge = userBadge.badge;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => controller.onBadgeTapped(userBadge),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge image or icon
              Expanded(
                flex: 3,
                child: badge != null && badge.imageUrl.isNotEmpty
                    ? Image.network(
                        badge.imageUrl,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emoji_events,
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
                          Icons.emoji_events,
                          size: 64,
                          color: Colors.amber.shade800,
                        ),
                      ),
              ),
              
              const SizedBox(height: 8),
              
              // Badge title
              Text(
                badge != null ? badge.name : 'Rozet #${userBadge.badgeId}',
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
              if (badge != null && badge.description.isNotEmpty)
                Expanded(
                  flex: 1,
                  child: Text(
                    badge.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Earned date
              if (userBadge.earnedDate.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _formatDate(userBadge.earnedDate),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Badge category if available
              if (badge != null && badge.category != null && badge.category!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge.category!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Tarih formatı düzenlemesi
  String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return '';
      
      // ISO formatı (2023-05-15T14:30:00Z) veya sadece tarih (2023-05-15) olabilir
      final date = DateTime.parse(dateStr);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      print('Tarih formatı hatası: $e');
      return dateStr;
    }
  }
} 