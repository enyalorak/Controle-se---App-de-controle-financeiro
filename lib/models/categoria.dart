class Categoria {
  String? id;
  final String nome;
  final String icone;
  final String cor;
  final String usuarioId;

  Categoria({
    this.id,
    required this.nome,
    required this.icone,
    required this.cor,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() {
    return {'nome': nome, 'icone': icone, 'cor': cor, 'usuarioId': usuarioId};
  }

  factory Categoria.fromMap(Map<String, dynamic> map, String id) {
    return Categoria(
      id: id,
      nome: map['nome'],
      icone: map['icone'],
      cor: map['cor'],
      usuarioId: map['usuarioId'],
    );
  }
}
