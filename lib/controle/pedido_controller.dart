import '../modelo/api_service.dart';
import '../modelo/classes/item_pedido.dart';
import '../modelo/classes/pedido.dart';
import '../modelo/local_storage_service.dart';

/// Pedidos do cliente logado. Um pedido nasce quando o cliente finaliza
/// a compra do carrinho (o carrinho em si fica só no app).
class PedidoController {
  // Create

  /// Envia o carrinho para o servidor, que cria os pedidos.
  static Future<void> criarPedido({required List<ItemPedido> itens}) async {
    await ApiService.post('/pedidos', autenticado: true, corpo: {
      'itens': itens
          .map((item) => {
                'produto_id': item.produtoId,
                'quantidade': item.quantidade,
              })
          .toList(),
    });
  }

  // Read

  static Future<ResultadoLista<Pedido>> listarPedidos() async {
    try {
      final resposta = await ApiService.get('/pedidos', autenticado: true);
      final List<Pedido> pedidos = (resposta as List<dynamic>)
          .map<Pedido>((item) => Pedido.fromApi(item))
          .toList();

      // Guarda uma cópia para poder mostrar os pedidos sem internet
      await LocalStorageService.salvarPedidos(pedidos);
      return ResultadoLista(pedidos);
    } on ApiException catch (erro) {
      if (!erro.semConexao) rethrow;

      final List<Pedido> copia = await LocalStorageService.carregarPedidos();
      return ResultadoLista(copia, offline: true);
    }
  }

  // Delete

  /// Cancela um pedido (o servidor só aceita se ele ainda estiver pendente).
  static Future<void> cancelarPedido(int pedidoId) async {
    await ApiService.delete('/pedidos/$pedidoId', autenticado: true);
  }
}
