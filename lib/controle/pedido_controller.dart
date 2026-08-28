import '../modelo/classes/item_pedido.dart';
import '../modelo/classes/pedido.dart';
import '../modelo/local_storage_service.dart';

/// CRUD de Pedido. Um pedido nasce quando o cliente finaliza a
/// compra do carrinho.
class PedidoController {
  // Create

  static Future<Pedido> criarPedido({
    required int clienteId,
    required List<ItemPedido> itens,
  }) async {
    List<Pedido> lista = await LocalStorageService.carregarPedidos();

    final int novoId = lista.isEmpty
        ? 1
        : lista.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

    final novoPedido = Pedido(
      id: novoId,
      clienteId: clienteId,
      itens: itens,
      data: DateTime.now().toIso8601String(),
    );

    lista.add(novoPedido);
    await LocalStorageService.salvarPedidos(lista);
    return novoPedido;
  }

  // Read

  static Future<List<Pedido>> listarPedidosDoCliente(int clienteId) async {
    List<Pedido> lista = await LocalStorageService.carregarPedidos();
    return lista.where((p) => p.clienteId == clienteId).toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  // Update

  static Future<void> atualizarQuantidadeItem({
    required int pedidoId,
    required int produtoId,
    required int novaQuantidade,
  }) async {
    List<Pedido> lista = await LocalStorageService.carregarPedidos();
    final int index = lista.indexWhere((p) => p.id == pedidoId);
    if (index == -1) return;

    final List<ItemPedido> novosItens = lista[index].itens.map((item) {
      if (item.produtoId == produtoId) {
        return item.copiarComQuantidade(novaQuantidade);
      }
      return item;
    }).toList();

    lista[index] = lista[index].copiarComItens(novosItens);
    await LocalStorageService.salvarPedidos(lista);
  }

  // Delete

  static Future<void> excluirPedido(int pedidoId) async {
    List<Pedido> lista = await LocalStorageService.carregarPedidos();
    lista.removeWhere((p) => p.id == pedidoId);
    await LocalStorageService.salvarPedidos(lista);
  }

  /// Usado ao excluir a conta do cliente: apaga o histórico de pedidos junto.
  static Future<void> excluirPedidosDoCliente(int clienteId) async {
    List<Pedido> lista = await LocalStorageService.carregarPedidos();
    lista.removeWhere((p) => p.clienteId == clienteId);
    await LocalStorageService.salvarPedidos(lista);
  }
}
