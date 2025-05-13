import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BaseController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  void setLoading(bool value) {
    _isLoading.value = value;
  }

  void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
} 