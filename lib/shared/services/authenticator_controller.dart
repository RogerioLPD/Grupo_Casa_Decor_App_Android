import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthenticationController {
  final StreamController<bool> loginLoading = StreamController();
  final StreamController<bool> loginCheckLoading = StreamController();

  AuthenticationController() {
    loginLoading.sink.add(false);
    checkAuthentication();
  }

  checkAuthentication() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');

    if (token != null) {
      loginCheckLoading.sink.add(true);
      return true;
    } else {
      loginCheckLoading.sink.add(false);
      return false;
    }
  }

  Future<bool> doLogin(String email, String password) async {
    loginLoading.sink.add(true);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var url = Uri.https("apicasadecor.com", "/login/");
    Map<String, String> headers = {
      //"Access-Control-Allow-Origin": "*",
      'content-type': 'application/json',
      //'Accept': '*/*'
    };
    Map<String, dynamic> body = {
      "username": email.trim(),
      "password": password.trim(),
    };
    var response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      String token = jsonDecode(response.body)['token'];
      if (token.isNotEmpty) {
        await sharedPreferences.setString('token', token);
      }
      if (kDebugMode) {
        print(sharedPreferences.getString('token'));
      }
      loginLoading.sink.add(false);
      return true;
    } else {
      loginLoading.sink.add(false);
      return false;
    }
  }

  doLogout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }
}
