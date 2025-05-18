import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'flight_controller.dart';
import 'package:mapico/models/flight_model.dart';

class FlightScreen extends GetView<FlightController> {
  const FlightScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uçuşlar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadFlights,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: GetBuilder<FlightController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Uçuşlar yükleniyor...', style: TextStyle(color: Colors.grey)),
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
                          'Test modunda çalışıyor (Token kullanılmıyor)',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Ana içerik
              Expanded(
                child: Obx(() {
                  if (controller.flights.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flight_takeoff,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage != null 
                                ? 'Hata Oluştu' 
                                : 'Uçuş bulunamadı',
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
                            onPressed: controller.loadFlights,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Yenile'),
                          ),
                          TextButton(
                            onPressed: controller.testConnection,
                            child: const Text('API Bağlantısını Test Et'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.onRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.flights.length,
                      itemBuilder: (context, index) {
                        final flight = controller.flights[index];
                        return _buildFlightCard(context, flight);
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

  Widget _buildFlightCard(BuildContext context, FlightModel flight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => controller.onFlightTapped(flight),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.flight,
                    color: Colors.blue,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      flight.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.airplane_ticket,
                          size: 16,
                          color: Colors.blue.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Uçuş #${flight.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                flight.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => controller.onFlightTapped(flight),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Detaylar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 