class Prize {
  final String id;
  final String name;
  final String description;
  final int pointsRequired;
  final String category;
  final String imageUrl;
  final bool isAvailable;
  final int quantity;
  final DateTime createdAt;
  final DateTime? expiryDate;

  Prize({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsRequired,
    required this.category,
    required this.imageUrl,
    this.isAvailable = true,
    required this.quantity,
    required this.createdAt,
    this.expiryDate,
  });

  factory Prize.fromMap(Map<String, dynamic> map) => Prize(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        pointsRequired: map['pointsRequired'] ?? 0,
        category: map['category'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        isAvailable: map['isAvailable'] ?? true,
        quantity: map['quantity'] ?? 0,
        createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
        expiryDate: map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'pointsRequired': pointsRequired,
        'category': category,
        'imageUrl': imageUrl,
        'isAvailable': isAvailable,
        'quantity': quantity,
        'createdAt': createdAt.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
      };
}
