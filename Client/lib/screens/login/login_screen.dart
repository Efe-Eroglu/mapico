import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mapico/core/utils/validators.dart';
import 'package:mapico/widgets/app_text_field.dart';
import 'package:mapico/widgets/custom_button.dart';
import 'package:mapico/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final authService = AuthService();
      final token = await authService.login(
        username: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() {
        _isLoading = false;
      });
      if (token != null) {
        // Ana sayfaya yönlendir
        Get.offAllNamed('/home');
      } else {
        // Hata mesajı göster
        Get.snackbar(
          'Giriş Başarısız',
          'Kullanıcı adı veya şifre hatalı.',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.black,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🎨 Arka plan görseli
          Positioned.fill(
            child: Image.asset(
              'assets/images/giris.png',
              fit: BoxFit.cover,
            ),
          ),
          // 🧼 Şeffaf beyaz katman
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "🎉 Hoş Geldin Küçük Kaşif!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B3F72),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // 🚀 Lottie animasyonu
                        Lottie.network(
                          'https://lottie.host/2a8c8fce-de75-4765-9c5e-c4ab63113062/1mlLfyBOM3.json',
                          height: 160,
                          repeat: true,
                        ),

                        const SizedBox(height: 24),

                        AppTextField(
                          controller: _emailController,
                          label: '📧 E-posta',
                          validator: validateEmail,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _passwordController,
                          label: '🔒 Şifre',
                          obscureText: true,
                          validator: (value) =>
                              value!.length < 4 ? 'En az 4 karakter' : null,
                        ),
                        const SizedBox(height: 24),

                        CustomButton(
                          text: '🚀 Giriş Yap',
                          onPressed: _isLoading ? null : _handleLogin,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Şifreni unuttun mu? yardım iste! 👩‍🏫',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        TextButton(
                          onPressed: () => Get.toNamed('/register'),
                          child: const Text('Hesabın yok mu? Kayıt ol'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
