// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/features/auth/presentation/pages/specifier_login_page.dart';
import 'package:nucleo_casa_decor_android/features/specifier/presentation/pages/specifier_navigation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      // Aqui você pode até validar o token com a API se quiser
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginEspecificador()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
