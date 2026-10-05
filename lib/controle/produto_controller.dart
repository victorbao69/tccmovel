import '../modelo/api_service.dart';
import '../modelo/classes/produto.dart';
import '../modelo/local_storage_service.dart';

/// Catálogo de móveis. Os produtos vêm da API do site (cadastrados pelas
/// empresas); o app só lista. Os favoritos ficam guardados no aparelho.
class ProdutoController {
  // Read

  /// [busca] é opcional: se vier preenchida, a API devolve só os produtos
  /// cujo nome contém o texto (GET /produtos?busca=...).
  static Future<ResultadoLista<Produto>> listar({String busca = ''}) async {
    final List<int> favoritos = await LocalStorageService.carregarFavoritos();

    try {
      final String caminho = busca.isEmpty
          ? '/produtos'
          : '/produtos?busca=${Uri.encodeQueryComponent(busca)}';
      final resposta = await ApiService.get(caminho);
      final List<Produto> produtos = (resposta as List<dynamic>)
          .map<Produto>((item) => Produto.fromMap(item))
          .toList();

      // Guarda uma cópia para poder mostrar o catálogo sem internet
      // (só a lista completa: uma busca não pode sobrescrever a cópia)
      if (busca.isEmpty) {
        await LocalStorageService.salvarProdutos(produtos);
      }
      return ResultadoLista(_marcarFavoritos(produtos, favoritos));
    } on ApiException catch (erro) {
      if (!erro.semConexao) rethrow;

      final List<Produto> copia = await LocalStorageService.carregarProdutos();
      final List<Produto> filtrada = busca.isEmpty
          ? copia
          : copia
              .where((p) => p.nome.toLowerCase().contains(busca.toLowerCase()))
              .toList();
      return ResultadoLista(_marcarFavoritos(filtrada, favoritos), offline: true);
    }
  }

  // Favoritos (só no aparelho)

  static Future<void> favoritar(Produto produto) async {
    final List<int> favoritos = await LocalStorageService.carregarFavoritos();

    if (favoritos.contains(produto.id)) {
      favoritos.remove(produto.id);
    } else {
      favoritos.add(produto.id);
    }

    await LocalStorageService.salvarFavoritos(favoritos);
  }

  static List<Produto> _marcarFavoritos(List<Produto> produtos, List<int> favoritos) {
    return produtos
        .map((p) => p.copiarCom(favorito: favoritos.contains(p.id)))
        .toList();
  }
}
