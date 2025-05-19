import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = controller.userInfo.value;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profil
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, size: 32, color: Colors.blue),
                ),
                title: Text(user?['full_name'] ?? 'Kullanıcı Adı'),
                subtitle: Text(user?['email'] ?? 'kullanici@email.com'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                  tooltip: 'Profili Düzenle',
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Tema
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: SwitchListTile(
                title: const Text('Koyu Mod'),
                secondary: const Icon(Icons.dark_mode),
                value: false, // TODO: Bağlantı ekle
                onChanged: (val) {},
              ),
            ),
            const SizedBox(height: 12),
            // Bildirimler
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: SwitchListTile(
                title: const Text('Bildirimler'),
                secondary: const Icon(Icons.notifications_active),
                value: true, // TODO: Bağlantı ekle
                onChanged: (val) {},
              ),
            ),
            const SizedBox(height: 12),
            // Dil
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Dil'),
                subtitle: const Text('Türkçe'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            // Hakkında
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Hakkında'),
                subtitle: const Text('Uygulama Sürümü: 1.0.0'),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),
            // Çıkış
            Card(
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
                onTap: controller.logout,
              ),
            ),
          ],
        );
      }),
    );
  }
} 