import '../modelo/api_service.dart';
import '../modelo/classes/item_pedido.dart';
import '../modelo/local_storage_service.dart';

/// Carrinho de compras. Ele fica guardado no servidor (API), então o cliente
/// vê o mesmo carrinho em qualquer aparelho. O aparelho só guarda uma cópia
/// para mostrar o carrinho quando estiver sem internet.
class CarrinhoController {
  // Read

  static Future<ResultadoLista<ItemPedido>> listar() async {
    try {
      final resposta = await ApiService.get('/carrinho', autenticado: true);
      final List<ItemPedido> itens = (resposta['itens'] as List<dynamic>)
          .map<ItemPedido>((item) => ItemPedido.fromCarrinhoApi(item))
          .toList();

      await LocalStorageService.salvarCarrinho(itens);
      return ResultadoLista(itens);
    } on ApiException catch (erro) {
      if (!erro.semConexao) rethrow;

      final List<ItemPedido> copia = await LocalStorageService.carregarCarrinho();
      return ResultadoLista(copia, offline: true);
    }
  }

  // Create

  static Future<void> adicionar(int produtoId, int quantidade) async {
    await ApiService.post('/carrinho', autenticado: true, corpo: {
      'produto_id': produtoId,
      'quantidade': quantidade,
    });
  }

  // Update

  static Future<void> alterarQuantidade(int produtoId, int quantidade) async {
    await ApiService.put('/carrinho/$produtoId',
        autenticado: true, corpo: {'quantidade': quantidade});
  }

  // Delete

  static Future<void> remover(int produtoId) async {
    await ApiService.delete('/carrinho/$produtoId', autenticado: true);
  }

  /// Finalizar compra: o servidor transforma o carrinho em pedidos e o esvazia.
  static Future<void> finalizar() async {
    await ApiService.post('/carrinho/finalizar', autenticado: true);
    await LocalStorageService.salvarCarrinho([]);
  }
}
