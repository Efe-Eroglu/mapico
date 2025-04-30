import 'package:flutter/material.dart';
import 'package:mapico/screens/login/login_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (_) => const LoginScreen(),
    
  };
}
