import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Purchase {
  final int id;
  final String especificador;
  final String empresa;
  final String valor;
  double get multipliedValue => double.parse(valor) * 1000;
  String get formattedMultipliedValue =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(multipliedValue);

  Purchase({
    required this.id,
    required this.especificador,
    required this.empresa,
    required this.valor,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      especificador: json['especificador']['nome'],
      empresa: json['empresa']['nome'],
      valor: json['valor'],
    );
  }
}

class RankedData {
  final String especificador;
  final double valor;
  final double pontos;

  RankedData(this.especificador, this.valor, this.pontos);
}

class ReleasesPage1 extends StatefulWidget {
  const ReleasesPage1({super.key});

  @override
  _ReleasesPage1State createState() => _ReleasesPage1State();
}

class _ReleasesPage1State extends State<ReleasesPage1> {
  List<Purchase> _purchases = [];
  final Map<String, double> _sumsByEspecificador = {};

  List<RankedData> get sortedRankedData => _sumsByEspecificador.entries
      .map((entry) => RankedData(entry.key, entry.value, entry.value / 1000))
      .toList()
    ..sort((a, b) => b.valor.compareTo(a.valor));

  @override
  void initState() {
    super.initState();
    _fetchPurchases();
  }

  Future<void> _fetchPurchases() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');

    var url = Uri.parse("https://apicasadecor.com/api/compra/");
    Map<String, String> headers = {
      'Authorization': token!,
      'Content-Type': 'application/json',
    };

    try {
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        var purchaseData = jsonDecode(responseBody);
        setState(() {
          _purchases = List<Purchase>.from(
              purchaseData.map((purchaseJson) => Purchase.fromJson(purchaseJson)));
          _calculateSumsByEspecificador();
        });
      } else {
        print('Failed to fetch purchases.');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _calculateSumsByEspecificador() {
    _sumsByEspecificador.clear();

    for (var purchase in _purchases) {
      final especificador = purchase.especificador;
      final valor = double.parse(purchase.valor) * 1000;

      if (_sumsByEspecificador.containsKey(especificador)) {
        _sumsByEspecificador[especificador] = _sumsByEspecificador[especificador]! + valor;
      } else {
        _sumsByEspecificador[especificador] = valor;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
      ),
      body: _purchases.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _purchases.length,
                    itemBuilder: (context, index) {
                      final purchase = _purchases[index];
                      return ListTile(
                        title: Text('Arquiteto(a): ${purchase.especificador}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Loja: ${purchase.empresa}'),
                            Text('Pontos: ${purchase.valor}'),
                            Text('Valor: ${purchase.formattedMultipliedValue}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: Column(
                    children: sortedRankedData
                        .asMap()
                        .entries
                        .map((entry) => Text(
                              '${entry.key + 1}: ${entry.value.especificador}: Pontos: ${entry.value.pontos} - Valor: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(entry.value.valor)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
