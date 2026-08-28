import 'dart:convert';
import 'item_pedido.dart';

/// Representa um pedido finalizado por um cliente.
class Pedido {
  final int id;
  final int clienteId;
  final List<ItemPedido> itens;
  final String data;

  Pedido({
    required this.id,
    required this.clienteId,
    required this.itens,
    required this.data,
  });

  double get total =>
      itens.fold(0.0, (soma, item) => soma + item.subtotal);

  Pedido copiarComItens(List<ItemPedido> novosItens) {
    return Pedido(
      id: id,
      clienteId: clienteId,
      itens: novosItens,
      data: data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteId': clienteId,
      'itens': itens.map((i) => i.toMap()).toList(),
      'data': data,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'] ?? 0,
      clienteId: map['clienteId'] ?? 0,
      itens: (map['itens'] as List<dynamic>? ?? [])
          .map((i) => ItemPedido.fromMap(i))
          .toList(),
      data: map['data'] ?? '',
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
