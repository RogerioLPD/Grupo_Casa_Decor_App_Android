// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nucleo_casa_decor_android/app/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final BuildContext context;
  final String email;
  final String senha;

  AuthService({
    required this.context,
    required this.email,
    required this.senha,
  });

  Future<bool> fazerLogin() async {
    debugPrint('🔥 MÉTODO fazerLogin() FOI CHAMADO');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var url = Uri.parse('https://apicasadecor.com/login/');

    Map<String, dynamic> body = {
      'username': email.trim(),
      'password': senha.trim(),
    };

    try {
      var response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json.containsKey('token') && (json['token'] as String).isNotEmpty) {
          String token = json['token'];
          await sharedPreferences.setString('token', "Token $token");
          if (kDebugMode) {
            print("TOKEN: $token");
          }
          await _buscarUsuarioETrocarRota(token);
          return true;
        } else {
          _mostrarErro("Token inválido recebido.");
          return false;
        }
      } else {
        _mostrarErro("Credenciais inválidas.");
        return false;
      }
    } catch (e) {
      _mostrarErro("Erro na conexão: $e");
      return false;
    }
  }

  Future<void> _buscarUsuarioETrocarRota(String token) async {
    var url = Uri.parse('https://apicasadecor.com/api/usuario/1');

    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var userData = jsonDecode(response.body);

        String segmento = userData['seguimento'] ?? '';
        String tipo = userData['tipo'] ?? '';

        if (kDebugMode) {
          print('Seguimento: $segmento');
          print('Tipo: $tipo');
        }

        if (segmento.toUpperCase() == 'ADMIN') {
          Navigator.pushReplacementNamed(context, Routes.homeAdm);
        } else if (tipo.toUpperCase() == 'EMPRESA') {
          Navigator.pushReplacementNamed(context, Routes.homeCompany);
        } else if (tipo.toUpperCase() == 'ESPECIFICADOR') {
          Navigator.pushReplacementNamed(context, Routes.main_navigation);
        } else {
          _mostrarErro("Tipo de usuário não reconhecido.");
          Navigator.pushReplacementNamed(context, Routes.login);
        }
      } else {
        _mostrarErro("Erro ao buscar dados do usuário.");
      }
    } catch (e) {
      _mostrarErro("Erro ao buscar usuário: $e");
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }
}
