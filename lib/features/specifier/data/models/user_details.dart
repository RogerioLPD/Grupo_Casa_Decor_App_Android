class UserDetails {
  int? id;
  String? photo;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? nome;
  String? segment;
  String? type;
  String? cnpj;
  String? cpf;
  String? phone;
  String? cellPhone;
  String? address;
  String? number;
  String? district;
  String? city;
  String? state;
  String? cep;

  UserDetails({
    this.id,
    this.photo,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.nome,
    this.segment,
    this.type,
    this.cnpj,
    this.cpf,
    this.phone,
    this.cellPhone,
    this.address,
    this.number,
    this.district,
    this.city,
    this.state,
    this.cep,
  });

  UserDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    photo = json['foto'];
    username = json['username'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    nome = json['nome'];
    segment = json['seguimento'];
    type = json['tipo'];
    cnpj = json['cnpj'];
    cpf = json['cpf'];
    phone = json['telefone'];
    cellPhone = json['celular'];
    address = json['endereco'];
    number = json['numero'];
    district = json['bairro'];
    city = json['cidade'];
    state = json['estado'];
    cep = json['cep'];

    // Definir valores padrão para campos que podem ser nulos
    photo ??= ''; // Se photo for nulo, definimos uma string vazia
    segment ??= '';
    type ??= '';
    cnpj ??= '';
    cpf ??= '';
    phone ??= '';
    cellPhone ??= '';
    address ??= '';
    number ??= '';
    district ??= '';
    city ??= '';
    state ??= '';
    cep ??= '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['foto'] = photo;
    data['username'] = username;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['nome'] = nome;
    data['seguimento'] = segment;
    data['tipo'] = type;
    data['cnpj'] = cnpj;
    data['cpf'] = cpf;
    data['telefone'] = phone;
    data['celular'] = cellPhone;
    data['endereco'] = address;
    data['numero'] = number;
    data['bairro'] = district;
    data['cidade'] = city;
    data['estado'] = state;
    data['cep'] = cep;
    return data;
  }
}
