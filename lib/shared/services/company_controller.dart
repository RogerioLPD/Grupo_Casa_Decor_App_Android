import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:nucleo_casa_decor_android/mobile/models/enterprise_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CompanyController {
  StreamController<List<EnterpriseItem>> userListController = StreamController.broadcast();
  StreamController<List<String>> cityController = StreamController.broadcast();
  StreamController<bool> isLoadingController = StreamController.broadcast();
  StreamController<bool> isLoadingSearch = StreamController.broadcast();

  List<EnterpriseItem> userList = [];

  CompanyController() {
    initValues();
  }

  initValues() async {
    await getData();
    isLoadingSearch.sink.add(false);
  }

  Future<void> getData() async {
    isLoadingController.sink.add(true);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');

    var url = Uri.https("apicasadecor.com", "/api/usuario/");
    Map<String, String> headers = {
      'Authorization': token ?? '',
      'Content-Type': 'application/json',
    };

    try {
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        var decoded = jsonDecode(utf8.decode(response.bodyBytes)) as List;

        userList = decoded.map((data) => EnterpriseItem.fromJson(data)).toList();

        userListController.sink.add(userList);
      } else {
        log("Erro na requisição: ${response.statusCode}");
      }
    } catch (e) {
      log("Erro ao buscar empresas: $e");
    } finally {
      isLoadingController.sink.add(false);
    }
  }
}
