import 'dart:convert';
import 'item_pedido.dart';

/// Representa um pedido do cliente. Igual ao site: cada unidade comprada
/// é um pedido próprio, com um produto e um status
/// (pendente, pago, enviado ou concluido).
class Pedido {
  final int id;
  final List<ItemPedido> itens;
  final String data;
  final String status;

  Pedido({
    required this.id,
    required this.itens,
    required this.data,
    this.status = 'pendente',
  });

  double get total =>
      itens.fold(0.0, (soma, item) => soma + item.subtotal);

  /// Só pedidos pendentes podem ser cancelados (mesma regra do site).
  bool get podeCancelar => status == 'pendente';

  String get statusFormatado {
    switch (status) {
      case 'pago':
        return 'Pago';
      case 'enviado':
        return 'Enviado';
      case 'concluido':
        return 'Concluído';
      default:
        return 'Pendente';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itens': itens.map((i) => i.toMap()).toList(),
      'data': data,
      'status': status,
    };
  }

  /// Lê o pedido salvo no aparelho (cópia para uso sem internet).
  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'] ?? 0,
      itens: (map['itens'] as List<dynamic>? ?? [])
          .map((i) => ItemPedido.fromMap(i))
          .toList(),
      data: map['data'] ?? '',
      status: map['status'] ?? 'pendente',
    );
  }

  /// Lê o pedido como a API do site envia:
  /// {id, valor, status, data, produto: {id, nome, imagem_url}}
  factory Pedido.fromApi(Map<String, dynamic> map) {
    final Map<String, dynamic> produto = map['produto'] ?? {};
    return Pedido(
      id: map['id'] ?? 0,
      data: map['data'] ?? '',
      status: map['status'] ?? 'pendente',
      itens: [
        ItemPedido(
          produtoId: produto['id'] ?? 0,
          nomeProduto: produto['nome'] ?? '',
          precoUnitario: (map['valor'] ?? 0.0).toDouble(),
          quantidade: 1,
        ),
      ],
    );
  }

  static String encode(List<Pedido> pedidos) => json.encode(
        pedidos.map<Map<String, dynamic>>((p) => p.toMap()).toList(),
      );

  static List<Pedido> decode(String pedidosJson) =>
      (json.decode(pedidosJson) as List<dynamic>)
          .map<Pedido>((item) => Pedido.fromMap(item))
          .toList();
}
