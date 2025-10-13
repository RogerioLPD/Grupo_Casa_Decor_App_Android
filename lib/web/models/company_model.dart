class CompanyModel {
  final String id;
  final String name;
  final String cnpj;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String category;
  final bool isActive;
  final DateTime createdAt;
  final String imageUrl;
  final String description; // ✅ adicionado

  CompanyModel({
    required this.id,
    required this.name,
    required this.cnpj,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.category,
    this.isActive = true,
    required this.createdAt,
    this.imageUrl = '',
    this.description = '', // ✅ valor padrão
  });

  factory CompanyModel.fromMap(Map<String, dynamic> map) => CompanyModel(
        id: map['id']?.toString() ?? '',
        name: map['name'] ?? '',
        cnpj: map['cnpj'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        address: map['address'] ?? '',
        city: map['city'] ?? '',
        state: map['state'] ?? '',
        category: map['category'] ?? '',
        isActive: map['isActive'] ?? true,
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        imageUrl: map['imageUrl'] ?? '',
        description: map['description'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'cnpj': cnpj,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'state': state,
        'category': category,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'imageUrl': imageUrl,
        'description': description,
      };
}
