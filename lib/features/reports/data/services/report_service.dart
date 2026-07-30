import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReportService {
  final BuildContext context;

  ReportService({required this.context});

  /// 🔍 Função genérica para buscar usuários por tipo (ex: 'ESPECIFICADOR', 'EMPRESA')
  Future<Map<String, dynamic>?> fetchUsersByType(String userType) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString('token');

      if (token == null || token.isEmpty) {
        _mostrarErro("Token não encontrado. Faça login novamente.");
        return null;
      }

      final url = Uri.parse('https://apicasadecor.com/api/usuario/');
      final response = await http.get(
        url,
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);

        // Filtra os usuários pelo tipo informado
        final List<dynamic> filteredUsers =
            users
                .where(
                  (user) =>
                      (user['tipo'] ?? '').toString().toUpperCase() ==
                      userType.toUpperCase(),
                )
                .toList();

        return {'list': filteredUsers, 'count': filteredUsers.length};
      } else {
        _mostrarErro("Erro ao buscar usuários. Código: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      _mostrarErro("Erro ao buscar usuários: $e");
      return null;
    }
  }

  /// 👤 Lista todos os usuários do tipo **ESPECIFICADOR**
  Future<Map<String, dynamic>?> fetchEspecificadores() async {
    return await fetchUsersByType('ESPECIFICADOR');
  }

  /// 🏢 Lista todos os usuários do tipo **EMPRESA**
  Future<Map<String, dynamic>?> fetchEmpresas() async {
    return await fetchUsersByType('EMPRESA');
  }

  /// ⚠️ Exibe mensagem de erro no Snackbar
  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }
}
