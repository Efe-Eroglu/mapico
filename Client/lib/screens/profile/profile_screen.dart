import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapico/screens/profile/avatar_select_screen.dart';
import 'package:mapico/services/auth_service.dart';
import 'package:mapico/models/avatar_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mapico/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AvatarModel? _avatar;
  UserModel? _user;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAvatar();
  }

  Future<void> _fetchAvatar() async {
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
    final (avatar, avatarError) = await authService.getUserAvatar(token);
    final (user, userError) = await authService.getCurrentUser(token);
    setState(() {
      _avatar = avatar;
      _user = user;
      _error = avatarError ?? userError;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_error != null) ...[
                    Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                    const SizedBox(height: 24),
                  ] else if (_avatar == null) ...[
                    const Icon(Icons.person_outline, size: 80, color: Colors.grey),
                    const SizedBox(height: 24),
                    const Text('Henüz avatar seçmediniz', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 24),
                  ] else ...[
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage(_avatar!.imageUrl),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _avatar!.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _avatar!.description,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    if (_user != null) ...[
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(_user!.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.email, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(_user!.email, style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.cake, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(_user!.dateOfBirth, style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Get.to(() => const AvatarSelectScreen());
                      _fetchAvatar(); // Avatar seçildiyse güncelle
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Avatarı Değiştir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      const storage = FlutterSecureStorage();
                      await storage.delete(key: 'jwt_token');
                      Get.offAllNamed('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Çıkış Yap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
