class UserReport {
  final String id;
  final String userId;
  final String userName;
  final String userEmail; // email do especificador
  final String companyEmail; // email da empresa
  final String? companySegment; // 🆕 novo campo: seguimento da empresa
  final int totalPoints;
  final int usedPoints;
  final int availablePoints;
  final int totalPurchases;
  final double totalSpent;
  final List<String> favoriteStores;
  final DateTime lastActivity;
  final DateTime joinDate;
  final DateTime createdAt;

  UserReport({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.companyEmail,
    this.companySegment, // 🆕 campo opcional
    required this.totalPoints,
    required this.usedPoints,
    required this.totalPurchases,
    required this.totalSpent,
    required this.favoriteStores,
    required this.lastActivity,
    required this.joinDate,
    required this.createdAt,
  }) : availablePoints = totalPoints - usedPoints;

  factory UserReport.fromMap(Map<String, dynamic> map) => UserReport(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        userEmail: map['userEmail'] ?? '',
        companyEmail: map['companyEmail'] ?? '',
        companySegment: map['companySegment'], // 🆕 novo campo
        totalPoints: map['totalPoints'] ?? 0,
        usedPoints: map['usedPoints'] ?? 0,
        totalPurchases: map['totalPurchases'] ?? 0,
        totalSpent: (map['totalSpent'] ?? 0.0).toDouble(),
        favoriteStores: List<String>.from(map['favoriteStores'] ?? []),
        lastActivity: DateTime.parse(map['lastActivity'] ?? DateTime.now().toIso8601String()),
        joinDate: DateTime.parse(map['joinDate'] ?? DateTime.now().toIso8601String()),
        createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'companyEmail': companyEmail,
        'companySegment': companySegment, // 🆕 novo campo
        'totalPoints': totalPoints,
        'usedPoints': usedPoints,
        'availablePoints': availablePoints,
        'totalPurchases': totalPurchases,
        'totalSpent': totalSpent,
        'favoriteStores': favoriteStores,
        'lastActivity': lastActivity.toIso8601String(),
        'joinDate': joinDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };
}
