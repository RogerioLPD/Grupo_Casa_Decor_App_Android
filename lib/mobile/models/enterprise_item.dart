class EnterpriseItem {
  int? id; // novo campo id
  String? photo;
  String? name;
  String? city;
  String? tipo;

  EnterpriseItem({this.id, this.photo, this.name, this.city, this.tipo});

  EnterpriseItem.fromJson(Map<String, dynamic> json) {
    id = json['id']; // captura o id vindo do JSON
    photo = json['foto'];
    name = json['nome'];
    city = json['cidade'];
    tipo = json['tipo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id; // inclui o id no JSON
    data['foto'] = photo;
    data['nome'] = name;
    data['cidade'] = city;
    data['tipo'] = tipo;
    return data;
  }
}
