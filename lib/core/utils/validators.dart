String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email boş olamaz';
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(value)) return 'Geçersiz email formatı';
  return null;
}
