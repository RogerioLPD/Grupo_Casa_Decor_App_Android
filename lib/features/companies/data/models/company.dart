class Company {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;

  final String? phone;
  final String? address;

  final String? city; // 👈 NOVO

  const Company({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    this.phone,
    this.address,
    this.city, // 👈 NOVO
  });
}
