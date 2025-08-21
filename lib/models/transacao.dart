class Transacao {
  String? id;
  final String descricao;
  final double valor;
  final String tipo; // 'receita' ou 'despesa'
  final DateTime data;
  final String categoria;
  final String usuarioId;

  Transacao({
    this.id,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.data,
    required this.categoria,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'valor': valor,
      'tipo': tipo,
      'data': data.toIso8601String(),
      'categoria': categoria,
      'usuarioId': usuarioId,
    };
  }

  factory Transacao.fromMap(Map<String, dynamic> map, String id) {
    return Transacao(
      id: id,
      descricao: map['descricao'],
      valor: map['valor'].toDouble(),
      tipo: map['tipo'],
      data: DateTime.parse(map['data']),
      categoria: map['categoria'],
      usuarioId: map['usuarioId'],
    );
  }
}
