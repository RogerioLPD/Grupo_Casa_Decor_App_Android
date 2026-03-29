class EnterpriseItem {
  int? id;
  String? photo;
  String? name;
  String? city;
  String? tipo;

  // 🔥 NOVOS CAMPOS
  String? email;
  String? cnpj;
  String? segment;
  String? telephone;
  String? cellphone;
  String? address;
  String? number;
  String? neighborhood;
  String? state;

  EnterpriseItem({
    this.id,
    this.photo,
    this.name,
    this.city,
    this.tipo,
    this.email,
    this.cnpj,
    this.segment,
    this.telephone,
    this.cellphone,
    this.address,
    this.number,
    this.neighborhood,
    this.state,
  });

  EnterpriseItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    photo = json['foto'];
    name = json['nome'];
    city = json['cidade'];
    tipo = json['tipo'];

    // 🔥 NOVOS MAPEAMENTOS
    email = json['email'];
    cnpj = json['cnpj'];
    segment = json['seguimento'];
    telephone = json['telefone'];
    cellphone = json['celular'];
    address = json['endereco'];
    number = json['numero'];
    neighborhood = json['bairro'];
    state = json['estado'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['foto'] = photo;
    data['nome'] = name;
    data['cidade'] = city;
    data['tipo'] = tipo;

    data['email'] = email;
    data['cnpj'] = cnpj;
    data['seguimento'] = segment;
    data['telefone'] = telephone;
    data['celular'] = cellphone;
    data['endereco'] = address;
    data['numero'] = number;
    data['bairro'] = neighborhood;
    data['estado'] = state;

    return data;
  }
}
