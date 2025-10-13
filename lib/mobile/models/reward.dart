class RewardModel {
  final int? id;
  final String? titulo;
  final String? descricao;
  final int? pontos;
  final String? imagem1;
  // Outros campos opcionais (imagem2, imagem3...) podem ser adicionados aqui

  RewardModel({
    this.id,
    this.titulo,
    this.descricao,
    this.pontos,
    this.imagem1,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      pontos: json['pontos'],
      imagem1: json['imagem_1'],
    );
  }
}
