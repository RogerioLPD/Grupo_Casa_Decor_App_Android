import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String slugify(String text) {
  var slug = text.toLowerCase();

  // Remove acentos (exemplo básico)
  slug = slug
      .replaceAll(RegExp(r'[áàãâä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòõôö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll(RegExp(r'[ç]'), 'c');

  // Remove caracteres especiais
  slug = slug.replaceAll(RegExp(r'[^\w\s-]'), '');

  // Troca espaços por hífen
  slug = slug.replaceAll(RegExp(r'\s+'), '-');

  return slug;
}

Future<bool> deleteCompanyBySlug(String companyName, String token) async {
  final slug = slugify(companyName);
  final url = Uri.parse('https://apicasadecor.com/api/empresas/$slug/');

  final response = await http.delete(
    url,
    headers: {
      'Authorization': token,
      'Content-Type': 'application/json',
      'accept': 'application/json',
    },
  );

  if (response.statusCode == 200 || response.statusCode == 204) {
    return true;
  } else {
    if (kDebugMode) {
      print('Erro ao deletar: ${response.statusCode} - ${response.body}');
    }
    return false;
  }
}
