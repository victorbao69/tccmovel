import 'dart:convert';

/// Item de um pedido. Guarda nome e preço do produto no momento da
/// compra, para não mudar se o produto for alterado depois.
class ItemPedido {
  final int produtoId;
  final String nomeProduto;
  final double precoUnitario;
  final int quantidade;

  ItemPedido({
    required this.produtoId,
    required this.nomeProduto,
    required this.precoUnitario,
    required this.quantidade,
  });

  double get subtotal => precoUnitario * quantidade;

  ItemPedido copiarComQuantidade(int novaQuantidade) {
    return ItemPedido(
      produtoId: produtoId,
      nomeProduto: nomeProduto,
      precoUnitario: precoUnitario,
      quantidade: novaQuantidade,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'produtoId': produtoId,
      'nomeProduto': nomeProduto,
      'precoUnitario': precoUnitario,
      'quantidade': quantidade,
    };
  }

  factory ItemPedido.fromMap(Map<String, dynamic> map) {
    return ItemPedido(
      produtoId: map['produtoId'] ?? 0,
      nomeProduto: map['nomeProduto'] ?? '',
      precoUnitario: (map['precoUnitario'] ?? 0.0).toDouble(),
      quantidade: map['quantidade'] ?? 1,
    );
  }

  static String encode(List<ItemPedido> itens) => json.encode(
        itens.map<Map<String, dynamic>>((i) => i.toMap()).toList(),
      );

  static List<ItemPedido> decode(String itensJson) =>
      (json.decode(itensJson) as List<dynamic>)
          .map<ItemPedido>((item) => ItemPedido.fromMap(item))
          .toList();
}
