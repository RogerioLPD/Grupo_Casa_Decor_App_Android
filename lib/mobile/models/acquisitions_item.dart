class AcquisitionsItem {
  String? valor;
  Enterprise? empresa;

  AcquisitionsItem({this.valor, this.empresa});

  AcquisitionsItem.fromJson(Map<String, dynamic> json) {
    valor = json['valor'];
    empresa = json['empresa'] != null ? Enterprise.fromJson(json['empresa']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['valor'] = valor;
    if (empresa != null) {
      data['empresa'] = empresa!.toJson();
    }
    return data;
  }
}

class Enterprise {
  int? id;
  String? name;
  String? type;

  Enterprise({this.id, this.name, this.type});

  Enterprise.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['nome'];
    type = json['tipo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nome'] = name;
    data['tipo'] = type;
    return data;
  }
}
