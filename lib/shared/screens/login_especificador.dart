// ignore_for_file: prefer_interpolation_to_compose_strings, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/shared/models/login_form_layout.dart';
import 'package:nucleo_casa_decor_android/shared/services/authenticator_controller.dart';
import 'package:nucleo_casa_decor_android/shared/services/login_controller.dart';
import '../../routes.dart';

class LoginEspecificador extends StatefulWidget {
  const LoginEspecificador({super.key});

  @override
  State<LoginEspecificador> createState() => _LoginEspecificadorState();
}

class _LoginEspecificadorState extends State<LoginEspecificador> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool visivelSenha = true;

  final AuthenticationController auth = AuthenticationController();

  @override
  void initState() {
    checkLogin();
    super.initState();
  }

  checkLogin() async {
    var check = await auth.checkAuthentication();
    if (check) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.main_navigation);
      }
    }
  }

  void verSenha() {
    setState(() {
      visivelSenha = !visivelSenha;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.main_navigation,
            (Route<dynamic> route) => false,
          );
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
