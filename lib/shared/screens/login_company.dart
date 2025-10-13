// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/shared/models/login_form_layout.dart';
import 'package:nucleo_casa_decor_android/shared/services/login_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes.dart';
// Importa o novo serviço de login

class LoginCompany extends StatefulWidget {
  const LoginCompany({super.key});

  @override
  State<LoginCompany> createState() => _LoginCompanyState();
}

class _LoginCompanyState extends State<LoginCompany> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool visivelSenha = true;

  @override
  void initState() {
    super.initState();
    verToken();
  }

  void verSenha() {
    setState(() {
      visivelSenha = !visivelSenha;
    });
  }

  verToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    if (kDebugMode) {
      if (kDebugMode) {
        print('Token: $token');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushNamedAndRemoveUntil(context, Routes.home, (_) => false);
          return true;
        },
        child: LoginLayoutResponsivo(
          formKey: _formKey,
          emailController: _emailController,
          senhaController: _senhaController,
          isSenhaVisivel: !visivelSenha,
          onToggleSenha: verSenha,
          onLoginPressed: () async {
            if (_formKey.currentState!.validate()) {
              final authService = AuthService(
                context: context,
                email: _emailController.text,
                senha: _senhaController.text,
              );
              await authService.fazerLogin();
            }
          },
          onVoltar: () {
            Navigator.pushNamed(context, Routes.home);
          },
        ),
      ),
    );
  }
}
