import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapico/models/flight_model.dart';

class FlightDetailsScreen extends StatelessWidget {
  const FlightDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flight = Get.arguments as FlightModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uçuş Detayları'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.airplane_ticket,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Uçuş #${flight.id}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      flight.description,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Bu sayfa yakında daha fazla detayla güncellenecek',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 