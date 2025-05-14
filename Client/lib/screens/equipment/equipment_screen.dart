import 'package:flutter/material.dart';
import 'package:mapico/services/equipment_service.dart';
import 'package:mapico/models/equipment_model.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  List<EquipmentModel>? _equipmentList;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEquipment();
  }

  Future<void> _fetchEquipment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    final equipmentService = EquipmentService();
    final (equipment, error) = await equipmentService.getAllEquipment();
    
    setState(() {
      _equipmentList = equipment;
      _error = error;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ekipmanlar'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _fetchEquipment,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _equipmentList?.length ?? 0,
                    itemBuilder: (context, index) {
                      final equipment = _equipmentList![index];
                      
                      return Card(
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
