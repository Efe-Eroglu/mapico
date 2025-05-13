import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';

class WelcomeCard extends GetView<HomeController> {
  const WelcomeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
                      )
                    : const CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.person, size: 30),
                      )),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                            'Hoş Geldin, ${controller.user.value?.fullName ?? controller.userName.value}',
                            style: Theme.of(context).textTheme.titleLarge,
                          )),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            controller.userRole.value,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              'Hedefinize ulaşmak için %70 tamamlandı',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
} 