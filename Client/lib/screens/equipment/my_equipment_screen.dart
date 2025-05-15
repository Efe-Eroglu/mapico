import 'package:flutter/material.dart';
import 'package:mapico/models/user_equipment_model.dart';
import 'package:mapico/services/user_equipment_service.dart';
import 'package:get/get.dart';

class MyEquipmentScreen extends StatefulWidget {
  const MyEquipmentScreen({super.key});

  @override
  State<MyEquipmentScreen> createState() => _MyEquipmentScreenState();
}

class _MyEquipmentScreenState extends State<MyEquipmentScreen> {
  List<UserEquipmentModel>? _userEquipmentList;
  String? _error;
  bool _isLoading = true;
  final UserEquipmentService _userEquipmentService = UserEquipmentService();
  bool _dataChanged = false; // Veri değişikliği takibi

  @override
  void initState() {
    super.initState();
    _fetchUserEquipment();
  }

  @override
  void dispose() {
    // Eğer veri değişmişse, önceki sayfaya true değerini döndür
    if (_dataChanged) {
      Get.back(result: true);
    }
    super.dispose();
  }

  Future<void> _fetchUserEquipment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final (userEquipments, error) = await _userEquipmentService.getUserEquipments();
      
      if (mounted) {
        setState(() {
          _userEquipmentList = userEquipments;
          _error = error;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('MyEquipmentScreen _fetchUserEquipment error: $e');
      if (mounted) {
        setState(() {
          _error = 'Beklenmeyen hata: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeUserEquipment(UserEquipmentModel userEquipment) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final error = await _userEquipmentService.removeUserEquipment(userEquipment.id);
      
      if (error == null) {
        setState(() {
          _userEquipmentList?.removeWhere((item) => item.id == userEquipment.id);
          _dataChanged = true; // Veri değişikliğini işaretle
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ekipman kaldırıldı')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $error')),
        );
      }
    } catch (e) {
      print('MyEquipmentScreen _removeUserEquipment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Beklenmeyen hata: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ekipmanlarım'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Eğer veri değişmişse, önceki sayfaya true değerini döndür
            Get.back(result: _dataChanged);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _userEquipmentList == null || _userEquipmentList!.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchUserEquipment,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _userEquipmentList?.length ?? 0,
                        itemBuilder: (context, index) {
                          final userEquipment = _userEquipmentList![index];
                          final equipment = userEquipment.equipment;
                          
                          if (equipment == null) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text('Ekipman bilgisi yüklenemedi (ID: ${userEquipment.equipmentId})'),
                              ),
                            );
                          }
                          
                          return Dismissible(
                            key: Key('equipment_${userEquipment.id}'),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _removeUserEquipment(userEquipment),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Ekipman resmi
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(equipment.imageUrl),
                                      radius: 28,
                                      backgroundColor: Colors.grey.shade200,
                                      onBackgroundImageError: (_, __) {},
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Ekipman bilgileri
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            equipment.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            equipment.description,
                                            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                          ),
                                          if (equipment.category != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Kategori: ${equipment.category}',
                                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                            ),
                                          ],
                                          const SizedBox(height: 4),
                                          Text(
                                            'Eklenme: ${_formatDate(userEquipment.selectedAt)}',
                                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Kaldır butonu
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.red,
                                      onPressed: () => _removeUserEquipment(userEquipment),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.backpack_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz ekipman seçmediniz',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ekipmanlar sayfasından ekipman ekleyebilirsiniz',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Bilinmeyen hata',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchUserEquipment,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
} 