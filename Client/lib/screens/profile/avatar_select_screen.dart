import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapico/services/auth_service.dart';
import 'package:mapico/models/avatar_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AvatarSelectScreen extends StatefulWidget {
  const AvatarSelectScreen({super.key});

  @override
  State<AvatarSelectScreen> createState() => _AvatarSelectScreenState();
}

class _AvatarSelectScreenState extends State<AvatarSelectScreen> {
  List<AvatarModel> _avatars = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAvatars();
  }

  Future<void> _fetchAvatars() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      setState(() {
        _error = 'Oturum bulunamadı.';
        _isLoading = false;
      });
      return;
    }
    final authService = AuthService();
    final (avatars, error) = await authService.getAllAvatars(token);
    setState(() {
      _avatars = avatars;
      _error = error;
      _isLoading = false;
    });
  }

  Future<void> _selectAvatar(int avatarId) async {
    setState(() {
      _isLoading = true;
    });
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      setState(() {
        _error = 'Oturum bulunamadı.';
        _isLoading = false;
      });
      return;
    }
    final authService = AuthService();
    final error = await authService.updateUserAvatar(token, avatarId);
    setState(() {
      _isLoading = false;
    });
    if (error == null) {
      Get.back(); // Profil ekranına dön
      Get.snackbar('Başarılı', 'Avatarınız güncellendi!', backgroundColor: Colors.green.shade100, colorText: Colors.black);
    } else {
      Get.snackbar('Hata', error, backgroundColor: Colors.red.shade100, colorText: Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avatar Seç'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = _avatars[index];
                    return GestureDetector(
                      onTap: () => _selectAvatar(avatar.id),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundImage: NetworkImage(avatar.imageUrl),
                            ),
                            const SizedBox(height: 12),
                            Text(avatar.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(avatar.description, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 