import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapico/widgets/app_text_field.dart';
import 'package:mapico/widgets/custom_button.dart';
import 'package:mapico/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final authService = AuthService();
      final (user, error) = await authService.register(
        email: _emailController.text.trim(),
        fullName: _nameController.text.trim(),
        dateOfBirth: '2015-05-01', // Şimdilik sabit, ileride tarih seçici eklenebilir
        password: _passwordController.text.trim(),
      );
      setState(() {
        _isLoading = false;
      });
      if (user != null) {
        Get.snackbar(
          'Kayıt Başarılı',
          'Şimdi giriş yapabilirsiniz!',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.black,
        );
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          'Kayıt Başarısız',
          error ?? 'Bilinmeyen hata',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.black,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
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
                  AppTextField(
                    controller: _nameController,
                    label: '👤 İsim',
                    validator: (value) => value == null || value.isEmpty ? 'İsim gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _emailController,
                    label: '📧 E-posta',
                    validator: (value) => value != null && value.contains('@') ? null : 'Geçerli bir e-posta girin',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    label: '🔒 Şifre',
                    obscureText: true,
                    validator: (value) => value != null && value.length >= 4 ? null : 'En az 4 karakter',
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Kayıt Ol',
                    onPressed: _isLoading ? null : _handleRegister,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.offAllNamed('/login'),
                    child: const Text('Zaten hesabın var mı? Giriş yap'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 