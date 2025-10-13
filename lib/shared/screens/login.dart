// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/shared/services/authenticator_controller.dart';
import 'package:nucleo_casa_decor_android/shared/services/login_controller.dart';
import '../../routes.dart';

import 'package:nucleo_casa_decor_android/shared/models/login_form_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool visivelSenha = true;

  final AuthenticationController auth = AuthenticationController();

  checkLogin() async {
    var check = await auth.checkAuthentication();
    if (check) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.main_navigation);
      }
    }
  }

  @override
  void initState() {
    //checkLogin();
    super.initState();
  }

  void verSenha() {
    setState(() {
      visivelSenha = !visivelSenha;
    });
  }

  void getRoute() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushNamedAndRemoveUntil(context, Routes.home, (Route<dynamic> route) => false);
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
