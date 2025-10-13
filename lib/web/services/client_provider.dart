import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nucleo_casa_decor_android/web/models/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Sample data for demo purposes
final _sampleClients = [
  Client(
    id: '1',
    name: 'Maria Silva Arquitetura',
    cpfCnpj: '123.456.789-00',
    email: 'maria@arquitetura.com',
    totalPoints: 25.5,
    transactions: [
      Transaction(
        id: 't1',
        amount: 15000.0,
        pointsEarned: 15.0,
        date: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Compra de materiais - Loja Partner A',
      ),
      Transaction(
        id: 't2',
        amount: 8500.0,
        pointsEarned: 8.5,
        date: DateTime.now().subtract(const Duration(days: 12)),
        description: 'Móveis para projeto residencial',
      ),
      Transaction(
        id: 't3',
        amount: 2000.0,
        pointsEarned: 2.0,
        date: DateTime.now().subtract(const Duration(days: 20)),
        description: 'Acessórios decorativos',
      ),
    ],
  ),
  Client(
    id: '2',
    name: 'João Santos Design',
    cpfCnpj: '987.654.321-00',
    email: 'joao@design.com',
    totalPoints: 42.0,
    transactions: [
      Transaction(
        id: 't4',
        amount: 30000.0,
        pointsEarned: 30.0,
        date: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Projeto comercial completo',
      ),
      Transaction(
        id: 't5',
        amount: 12000.0,
        pointsEarned: 12.0,
        date: DateTime.now().subtract(const Duration(days: 8)),
        description: 'Iluminação especial',
      ),
    ],
  ),
  Client(
    id: '3',
    name: 'Ana Costa Interiores',
    cpfCnpj: '11.222.333/0001-44',
    email: 'ana@interiores.com',
    totalPoints: 18.7,
    transactions: [
      Transaction(
        id: 't6',
        amount: 9500.0,
        pointsEarned: 9.5,
        date: DateTime.now().subtract(const Duration(days: 7)),
        description: 'Tecidos e estofados',
      ),
      Transaction(
        id: 't7',
        amount: 9200.0,
        pointsEarned: 9.2,
        date: DateTime.now().subtract(const Duration(days: 15)),
        description: 'Papel de parede importado',
      ),
    ],
  ),
];

class ClientNotifier extends StateNotifier<List<Client>> {
  ClientNotifier() : super(_sampleClients) {
    _loadClients();
  }

  Future<void> _loadClients() async {
    final prefs = await SharedPreferences.getInstance();
    final clientsJson = prefs.getString('clients');
    if (clientsJson != null) {
      final clientsList = jsonDecode(clientsJson) as List;
      state = clientsList.map((json) => Client.fromJson(json)).toList();
    }
  }

  Future<void> _saveClients() async {
    final prefs = await SharedPreferences.getInstance();
    final clientsJson = jsonEncode(state.map((client) => client.toJson()).toList());
    await prefs.setString('clients', clientsJson);
  }

  Client? findByDocument(String document) {
    final cleanDocument = document.replaceAll(RegExp(r'[^\d]'), '');
    return state.cast<Client?>().firstWhere(
      (client) => client!.cpfCnpj.replaceAll(RegExp(r'[^\d]'), '') == cleanDocument,
      orElse: () => null,
    );
  }

  Future<void> addTransaction(String clientId, double amount) async {
    final pointsEarned = _calculatePoints(amount);
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      pointsEarned: pointsEarned,
      date: DateTime.now(),
      description: 'Compra realizada - R\$ ${amount.toStringAsFixed(2)}',
    );

    state =
        state.map((client) {
          if (client.id == clientId) {
            final updatedTransactions = [...client.transactions, transaction];
            final newTotalPoints = client.totalPoints + pointsEarned;
            return client.copyWith(transactions: updatedTransactions, totalPoints: newTotalPoints);
          }
          return client;
        }).toList();

    await _saveClients();
  }

  double _calculatePoints(double amount) {
    return amount / 1000.0; // 1 ponto para cada R$ 1000
  }
}

final clientProvider = StateNotifierProvider<ClientNotifier, List<Client>>((ref) {
  return ClientNotifier();
});

final selectedClientProvider = StateProvider<Client?>((ref) => null);
