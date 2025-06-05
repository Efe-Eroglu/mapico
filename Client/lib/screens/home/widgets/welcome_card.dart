import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';

class WelcomeCard extends GetView<HomeController> {
  const WelcomeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4B3F72), // Koyu mor
            Color(0xFF3C6997), // Mavi
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Obx(() => controller.avatar.value != null
                    ? CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(controller.avatar.value!.imageUrl),
                        backgroundColor: Colors.white.withOpacity(0.2),
                      )
                    : CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(Icons.person, size: 30, color: Colors.white),
                      )),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                            'Hoş Geldin, ${controller.user.value?.fullName ?? controller.userName.value}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            controller.userRole.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.7,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hedefinize ulaşmak için %70 tamamlandı',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 