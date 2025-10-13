class Client {
  final String id;
  final String name;
  final String cpfCnpj;
  final String email;
  final double totalPoints;
  final List<Transaction> transactions;

  const Client({
    required this.id,
    required this.name,
    required this.cpfCnpj,
    required this.email,
    required this.totalPoints,
    required this.transactions,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      cpfCnpj: json['cpfCnpj'],
      email: json['email'],
      totalPoints: json['totalPoints'].toDouble(),
      transactions: (json['transactions'] as List).map((e) => Transaction.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cpfCnpj': cpfCnpj,
      'email': email,
      'totalPoints': totalPoints,
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }

  Client copyWith({
    String? id,
    String? name,
    String? cpfCnpj,
    String? email,
    double? totalPoints,
    List<Transaction>? transactions,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      email: email ?? this.email,
      totalPoints: totalPoints ?? this.totalPoints,
      transactions: transactions ?? this.transactions,
    );
  }
}

class Transaction {
  final String id;
  final double amount;
  final double pointsEarned;
  final DateTime date;
  final String description;

  const Transaction({
    required this.id,
    required this.amount,
    required this.pointsEarned,
    required this.date,
    required this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      pointsEarned: json['pointsEarned'].toDouble(),
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'pointsEarned': pointsEarned,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
