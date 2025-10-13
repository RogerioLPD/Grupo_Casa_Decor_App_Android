import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:nucleo_casa_decor_android/mobile/models/company.dart';
import 'package:nucleo_casa_decor_android/mobile/models/enterprise_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EnterpriseController {
  final StreamController<List<Company>> _companyController = StreamController.broadcast();
  final StreamController<bool> _loadingController = StreamController.broadcast();
  final StreamController<String?> _errorController = StreamController.broadcast();

  Stream<List<Company>> get companyStream => _companyController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  Future<void> fetchCompanies() async {
    _loadingController.sink.add(true);
    _errorController.sink.add(null);

    final url = Uri.parse(
      'https://apicasadecor.com/api/empresa/',
    ); // Verifique se é 'empresa' ou 'empresas'

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (kDebugMode) {
        print("TOKEN: $token");
      }

      if (token.isEmpty) {
        log('Token vazio, autenticação necessária');
        _errorController.sink.add('Usuário não autenticado.');
        _companyController.sink.add([]);
        _loadingController.sink.add(false);
        return;
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));

        final companies =
            jsonData.map((jsonItem) {
              final enterpriseItem = EnterpriseItem.fromJson(jsonItem);
              return Company(
                id:
                    (enterpriseItem.id ?? 0)
                        .toString(), // Usa o id numérico vindo da API convertido para string
                name: enterpriseItem.name ?? '',
                description: enterpriseItem.city ?? '',
                imageUrl: enterpriseItem.photo ?? '',
                rating: 4.5,
              );
            }).toList();

        _companyController.sink.add(companies);
      } else {
        log('Erro ao buscar empresas. Status: ${response.statusCode}');
        _errorController.sink.add('Erro ao buscar empresas. Código: ${response.statusCode}');
        _companyController.sink.add([]);
      }
    } catch (e) {
      log('Erro na requisição: $e');
      _errorController.sink.add('Erro na requisição: $e');
      _companyController.sink.add([]);
    } finally {
      _loadingController.sink.add(false);
    }
  }

  Future<bool> deleteCompany(String companyId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      log('Token não encontrado para deletar empresa.');
      return false;
    }

    try {
      // 1️⃣ Buscar compras por empresa
      final comprasUrl = Uri.parse(
        'https://apicasadecor.com/api/compra/compras-por-empresa/$companyId/',
      );
      final comprasResponse = await http.get(
        comprasUrl,
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
      );

      if (comprasResponse.statusCode != 200) {
        log('Erro ao buscar compras. Status: ${comprasResponse.statusCode}');
        return false;
      }

      final List<dynamic> comprasData = json.decode(utf8.decode(comprasResponse.bodyBytes));

      // 2️⃣ Desvincular cada compra
      for (var compra in comprasData) {
        final compraId = compra['id'];
        if (compraId != null) {
          final desvincularUrl = Uri.parse(
            'https://apicasadecor.com/api/compra/desvincular-empresa/$compraId/',
          );

          final desvincularResponse = await http.post(
            desvincularUrl,
            headers: {
              'Authorization': token,
              'Content-Type': 'application/json',
              'accept': 'application/json',
            },
          );

          if (desvincularResponse.statusCode != 200 && desvincularResponse.statusCode != 204) {
            log('Erro ao desvincular compra $compraId. Status: ${desvincularResponse.statusCode}');
            return false;
          }
        }
      }

      // 3️⃣ Excluir a empresa somente após desvinculação bem-sucedida
      final deleteUrl = Uri.parse('https://apicasadecor.com/api/empresas/$companyId/');
      final deleteResponse = await http.delete(
        deleteUrl,
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
      );

      if (deleteResponse.statusCode == 204 || deleteResponse.statusCode == 200) {
        log('Empresa $companyId deletada com sucesso.');
        return true;
      } else {
        log('Erro ao deletar empresa. Status: ${deleteResponse.statusCode}');
        return false;
      }
    } catch (e) {
      log('Erro ao deletar empresa: $e');
      return false;
    }
  }

  void dispose() {
    _companyController.close();
    _loadingController.close();
    _errorController.close();
  }
}
