import '../modelo/classes/produto.dart';
import '../modelo/local_storage_service.dart';

/// CRUD de Produto (catálogo de móveis).
class ProdutoController {
  // Create

  static Future<Produto> inserir({
    required String nome,
    required String descricao,
    required double preco,
  }) async {
    List<Produto> lista = await LocalStorageService.carregarProdutos();

    final int novoId = lista.isEmpty
        ? 1
        : lista.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

    final novoProduto = Produto(
      id: novoId,
      nome: nome,
      descricao: descricao,
      preco: preco,
    );

    lista.add(novoProduto);
    await LocalStorageService.salvarProdutos(lista);
    return novoProduto;
  }

  // Read

  static Future<List<Produto>> listar() async {
    return await LocalStorageService.carregarProdutos();
  }

  static Future<Produto?> buscarPorId(int id) async {
    List<Produto> lista = await LocalStorageService.carregarProdutos();
    for (final produto in lista) {
      if (produto.id == id) return produto;
    }
    return null;
  }

  // Update

  static Future<void> atualizar(Produto produtoAtualizado) async {
    List<Produto> lista = await LocalStorageService.carregarProdutos();

    final int index = lista.indexWhere((p) => p.id == produtoAtualizado.id);
    if (index != -1) {
      lista[index] = produtoAtualizado;
      await LocalStorageService.salvarProdutos(lista);
    }
  }

  static Future<void> favoritar(Produto produto) async {
    await atualizar(produto.copiarCom(favorito: !produto.favorito));
  }

  // Delete

  static Future<void> excluir(int id) async {
    List<Produto> lista = await LocalStorageService.carregarProdutos();
    lista.removeWhere((p) => p.id == id);
    await LocalStorageService.salvarProdutos(lista);
  }
}
