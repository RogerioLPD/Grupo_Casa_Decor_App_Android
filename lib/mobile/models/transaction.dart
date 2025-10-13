enum TransactionType { earned, spent }

class PointTransaction {
  final String id;
  final String description;
  final double points; // ✅ agora é double
  final double valor; // ✅ agora é double
  final DateTime date;
  final TransactionType type;
  final String companyName;

  const PointTransaction({
    required this.id,
    required this.description,
    required this.points,
    required this.valor,
    required this.date,
    required this.type,
    required this.companyName,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    // Converte o valor corretamente mantendo 2 casas decimais
    final valorDouble = double.tryParse(json['valor']?.toString() ?? '0') ?? 0.0;
    final formattedValor = double.parse(valorDouble.toStringAsFixed(2)); // ✅ Precisão garantida

    return PointTransaction(
      id: json['id']?.toString() ?? '',
      description: json['descricao']?.toString() ?? '',
      valor: formattedValor, // ✅ mantém double
      points: formattedValor, // ✅ mantém double
      date:
          DateTime.parse(
            json['data_compra']?.toString() ?? DateTime.now().toIso8601String(),
          ).toLocal(),
      type: _parseType(json['tipo']?.toString()),
      companyName: json['empresa']?['nome']?.toString() ?? '',
    );
  }

  static TransactionType _parseType(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'saida':
        return TransactionType.spent;
      case 'entrada':
        return TransactionType.earned;
      default:
        return TransactionType.earned; // fallback
    }
  }
}
