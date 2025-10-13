import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserReportService {
  final BuildContext context;

  UserReportService({required this.context});

  // Função genérica para listar usuários por tipo
  Future<Map<String, dynamic>?> fetchUsersByType(String userType) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');

    if (token!.isEmpty) {
      _mostrarErro("Token não encontrado. Faça login novamente.");
      return null;
    }

    try {
      // Supondo que o endpoint /api/usuario/ retorna todos os usuários
      var url = Uri.parse('https://apicasadecor.com/api/usuario/');
      var response = await http.get(url, headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        List<dynamic> users = jsonDecode(response.body);

        // Filtra pelo tipo
        List<dynamic> filteredUsers = users
            .where(
                (user) => (user['tipo'] ?? '').toString().toUpperCase() == userType.toUpperCase())
            .toList();

        return {
          'list': filteredUsers,
          'count': filteredUsers.length,
        };
      } else {
        _mostrarErro("Erro ao buscar usuários. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      _mostrarErro("Erro ao buscar usuários: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchEspecificadores() async {
    return fetchUsersByType('ESPECIFICADOR');
  }

  Future<Map<String, dynamic>?> fetchEmpresas() async {
    return fetchUsersByType('EMPRESA');
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }
}
