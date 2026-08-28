import 'dart:convert';

/// Representa um produto do catálogo (móveis).
class Produto {
  final int id;
  final String nome;
  final String descricao;
  final double preco;
  final bool favorito;

  Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    this.favorito = false,
  });

  Produto copiarCom({
    String? nome,
    String? descricao,
    double? preco,
    bool? favorito,
  }) {
    return Produto(
      id: id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      favorito: favorito ?? this.favorito,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'favorito': favorito,
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'] ?? 0,
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      preco: (map['preco'] ?? 0.0).toDouble(),
      favorito: map['favorito'] ?? false,
    );
  }

  static String encode(List<Produto> produtos) => json.encode(
        produtos.map<Map<String, dynamic>>((p) => p.toMap()).toList(),
      );

  static List<Produto> decode(String produtosJson) =>
      (json.decode(produtosJson) as List<dynamic>)
          .map<Produto>((item) => Produto.fromMap(item))
          .toList();
}
