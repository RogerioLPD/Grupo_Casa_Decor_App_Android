import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/mobile/models/acquisitions_item.dart';
import 'package:nucleo_casa_decor_android/mobile/models/user_details.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class SpecifierController {
  // BehaviorSubjects com valor inicial
  final BehaviorSubject<List<AcquisitionsItem>> detailsController = BehaviorSubject.seeded([]);
  final BehaviorSubject<double> pointsController = BehaviorSubject.seeded(0.0);
  final BehaviorSubject<UserDetails?> userController = BehaviorSubject.seeded(null);

  final PageController pageController = PageController(initialPage: 0);

  SpecifierController() {
    initValues();
  }

  void dispose() {
    detailsController.close();
    pointsController.close();
    userController.close();
    pageController.dispose();
  }

  initValues() async {
    await getData();
    await getGetUser();
  }

  Future<void> getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');

    var url = Uri.https("apicasadecor.com", "/api/compras-especificador/");
    Map<String, String> headers = {
      'Authorization': token ?? '',
      'content-type': 'application/json',
    };

    try {
      var response = await http.get(url, headers: headers);
      if (kDebugMode) print('Response ${response.body}');

      if (response.statusCode == 200) {
        List<AcquisitionsItem> item =
            (jsonDecode(utf8.decode(response.bodyBytes)) as List)
                .map((data) => AcquisitionsItem.fromJson(data))
                .toList();

        double valueTotal = item.fold(0.0, (sum, data) => sum + double.parse(data.valor!));

        pointsController.add(valueTotal); // atualiza saldo
        detailsController.add(item); // atualiza lista de compras
      } else {
        if (kDebugMode) print('Erro ${response.statusCode} ao buscar dados de compras');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  getGetUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token')!;

    var url = Uri.https("apicasadecor.com", "/api/usuario/$token");
    Map<String, String> headers = {'Authorization': token, 'content-type': 'application/json'};

    try {
      var response = await http.get(url, headers: headers);
      if (kDebugMode) print('Response ${response.body}');

      if (response.statusCode == 200) {
        var jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
        UserDetails item = UserDetails.fromJson(jsonBody);
        userController.add(item);
      } else {
        if (kDebugMode) print('Erro ao obter usuário: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<UserDetails?> getUser(String cpfOuCnpj) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token')!;

    // Chama a API sem parâmetros, retorna lista completa de usuários
    var url = Uri.https("apicasadecor.com", "/api/usuario/");

    Map<String, String> headers = {'Authorization': token, 'content-type': 'application/json'};

    try {
      var response = await http.get(url, headers: headers);

      if (kDebugMode) {
        print('Response ${response.body}');
      }

      if (response.statusCode == 200) {
        // Decodifica o array de usuários
        List<dynamic> jsonBody = jsonDecode(utf8.decode(response.bodyBytes));

        // Procura o usuário que tenha CPF ou CNPJ igual ao informado
        final match = jsonBody.firstWhere(
          (e) =>
              (e['cpf'] != null && e['cpf'].replaceAll(RegExp(r'\D'), '') == cpfOuCnpj) ||
              (e['cnpj'] != null && e['cnpj'].replaceAll(RegExp(r'\D'), '') == cpfOuCnpj),
          orElse: () => null,
        );

        if (match != null) {
          UserDetails item = UserDetails.fromJson(match);

          // publica no stream
          userController.sink.add(item);

          // retorna o usuário
          return item;
        } else {
          return null; // não encontrou
        }
      } else {
        if (kDebugMode) {
          print('Erro ao obter usuários: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  // Função para converter arquivo de imagem em base64
  Future<String> _imageFileToBase64(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes(); // Corrigido para Web
    return base64Encode(bytes);
  }

  Future<bool> updateUserData(UserDetails user, {XFile? imageFile}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token') ?? '';

    var url = Uri.parse("https://apicasadecor.com/api/especificador-editar/${user.id}/");

    String? fotoBase64;
    if (imageFile != null) {
      fotoBase64 = await _imageFileToBase64(imageFile);
    }

    Map<String, dynamic> data = {
      if (user.segment != null && user.segment!.isNotEmpty) 'seguimento': user.segment,
      if (user.phone != null && user.phone!.isNotEmpty) 'telefone': user.phone,
      if (user.cellPhone != null && user.cellPhone!.isNotEmpty) 'celular': user.cellPhone,
      if (user.address != null && user.address!.isNotEmpty) 'endereco': user.address,
      if (user.number != null && user.number!.isNotEmpty) 'numero': user.number,
      if (user.district != null && user.district!.isNotEmpty) 'bairro': user.district,
      if (user.city != null && user.city!.isNotEmpty) 'cidade': user.city,
      if (user.state != null && user.state!.isNotEmpty) 'estado': user.state,
      if (fotoBase64 != null) 'foto': fotoBase64,
    };

    try {
      final response = await http.put(
        url,
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        debugPrint('Erro ao atualizar dados: ${response.statusCode}');
        debugPrint('Resposta do servidor: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Erro no envio: $e');
      return false;
    }
  }
}
