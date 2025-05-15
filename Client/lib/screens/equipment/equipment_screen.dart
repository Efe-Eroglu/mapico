import 'package:flutter/material.dart';
import 'package:mapico/services/equipment_service.dart';
import 'package:mapico/services/user_equipment_service.dart';
import 'package:mapico/models/equipment_model.dart';
import 'package:mapico/models/user_equipment_model.dart';
import 'package:mapico/screens/equipment/my_equipment_screen.dart';
import 'package:get/get.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final EquipmentService _equipmentService = EquipmentService();
  final UserEquipmentService _userEquipmentService = UserEquipmentService();
  
  List<EquipmentModel> _allEquipments = [];
  List<UserEquipmentModel> _userEquipments = [];
  List<EquipmentModel> _availableEquipments = [];
  
  String? _error;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLoadingFirstTime = true; // İlk yükleme kontrolü

  @override
  void initState() {
    super.initState();
    // initState'de sadece ilk yüklemeyi yap
    _loadData();
  }

  // Bu metodu kaldır, çünkü her sayfaya girdiğinde yeniden yükleme yaparak sorunlara neden olabilir
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _loadData();
  // }

  Future<void> _loadData() async {
    // Eğer zaten yükleme yapılıyorsa ve ilk yükleme değilse, işlemi atla
    if (_isLoading && !_isLoadingFirstTime) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Ekipmanlar yükleniyor...');
      
      // 1. Tüm ekipmanları yükle
      final (allEquipments, equipmentError) = await _equipmentService.getAllEquipment();
      
      if (equipmentError != null) {
        print('Ekipmanları yüklerken hata: $equipmentError');
        setState(() {
          _error = equipmentError;
          _isLoading = false;
          _isLoadingFirstTime = false;
        });
        return;
      }
      
      if (allEquipments == null || allEquipments.isEmpty) {
        print('Hiç ekipman bulunamadı');
        setState(() {
          _allEquipments = [];
          _availableEquipments = [];
          _isLoading = false;
          _isLoadingFirstTime = false;
        });
        return;
      }
      
      print('${allEquipments.length} ekipman yüklendi');
      
      // 2. Kullanıcının ekipmanlarını yükle
      final (userEquipments, userError) = await _userEquipmentService.getUserEquipments();
      
      if (userError != null) {
        print('Kullanıcı ekipmanlarını yüklerken hata: $userError');
        // Kullanıcı ekipmanları yüklenemese bile devam et, tüm ekipmanları göster
        setState(() {
          _allEquipments = allEquipments;
          _availableEquipments = allEquipments;
          _userEquipments = [];
          _isLoading = false;
          _isLoadingFirstTime = false;
        });
        return;
      }
      
      final userEquipmentList = userEquipments ?? [];
      print('${userEquipmentList.length} kullanıcı ekipmanı yüklendi');
      
      // 3. Kullanıcının sahip olmadığı ekipmanları filtrele
      final Set<int> userEquipmentIds = userEquipmentList
          .map((ue) => ue.equipmentId)
          .toSet();
      
      print('Kullanıcı ekipman ID\'leri: $userEquipmentIds');
      
      final List<EquipmentModel> availableEquipments = allEquipments
          .where((equipment) => !userEquipmentIds.contains(equipment.id))
          .toList();
      
      setState(() {
        _userEquipments = userEquipmentList;
        _allEquipments = allEquipments;
        _availableEquipments = availableEquipments;
        _isLoading = false;
        _isLoadingFirstTime = false;
      });
      
      print('${_availableEquipments.length} ekipman filtrelendi ve gösteriliyor');
      
    } catch (e) {
      print('Veri yüklenirken beklenmeyen hata: $e');
      setState(() {
        _error = 'Veri yüklenirken bir hata oluştu: $e';
        _isLoading = false;
        _isLoadingFirstTime = false;
      });
    }
  }

  Future<void> _addEquipment(EquipmentModel equipment) async {
    // Ekipman zaten kullanıcının ekipmanlarında var mı kontrol et
    final bool alreadyAdded = _userEquipments.any((ue) => ue.equipmentId == equipment.id);
    
    if (alreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu ekipman zaten ekipmanlarınızda bulunuyor.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      print('Ekipman ekleniyor: ${equipment.id} - ${equipment.name}');
      
      final (userEquipment, error) = await _userEquipmentService.addUserEquipment(equipment.id);
      
      if (error == null && userEquipment != null) {
        setState(() {
          // Eklenen ekipmanı kullanıcının ekipmanlarına ekle
          _userEquipments.add(userEquipment);
          
          // Ekipmanı mevcut ekipmanlar listesinden kaldır
          _availableEquipments.removeWhere((e) => e.id == equipment.id);
        });
        
        print('Ekipman başarıyla eklendi');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ekipman ekipmanlarınıza eklendi')),
        );
      } else {
        print('Ekipman eklenirken hata: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${error ?? "Bilinmeyen hata"}')),
        );
      }
    } catch (e) {
      print('Ekipman eklerken beklenmeyen hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem sırasında hata oluştu: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ekipmanlar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.backpack),
            onPressed: () => Get.to(() => const MyEquipmentScreen())?.then((_) => _loadData()),
            tooltip: 'Ekipmanlarım',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Ekipmanlar yükleniyor...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    if (_error != null) {
      return _buildErrorState();
    }
    
    if (_allEquipments.isEmpty) {
      return const Center(
        child: Text('Hiç ekipman bulunamadı', style: TextStyle(color: Colors.grey)),
      );
    }
    
    if (_availableEquipments.isEmpty) {
      return _buildEmptyState();
    }
    
    return _buildEquipmentList();
  }
  
  Widget _buildEquipmentList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availableEquipments.length,
        itemBuilder: (context, index) {
          final equipment = _availableEquipments[index];
          
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: _isSaving ? null : () => _addEquipment(equipment),
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
                        ],
                      ),
                    ),
                    
                    // Ekle ikonu
                    const Icon(
                      Icons.add_circle_outline,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tüm ekipmanları eklediniz',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ekipmanlarınızı görmek için "Ekipmanlarım" sayfasına gidin',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const MyEquipmentScreen())?.then((_) => _loadData()),
            icon: const Icon(Icons.backpack),
            label: const Text('Ekipmanlarım'),
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
              onPressed: _loadData,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
