import 'dart:convert';

/// Representa um produto do catálogo (móveis).
class Produto {
  final int id;
  final String nome;
  final String descricao;
  final double preco;
  final String imagemUrl;
  final bool favorito;

  Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    this.imagemUrl = '',
    this.favorito = false,
  });

  Produto copiarCom({bool? favorito}) {
    return Produto(
      id: id,
      nome: nome,
      descricao: descricao,
      preco: preco,
      imagemUrl: imagemUrl,
      favorito: favorito ?? this.favorito,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'imagem_url': imagemUrl,
    };
  }

  /// Serve tanto para a resposta da API quanto para a cópia salva no aparelho.
  /// O favorito não vem daqui: ele é guardado à parte no aparelho.
  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'] ?? 0,
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      preco: (map['preco'] ?? 0.0).toDouble(),
      imagemUrl: map['imagem_url'] ?? '',
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
