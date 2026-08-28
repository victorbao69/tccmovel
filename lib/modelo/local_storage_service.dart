import 'package:shared_preferences/shared_preferences.dart';
import 'classes/cliente.dart';
import 'classes/produto.dart';
import 'classes/pedido.dart';

/// Persistência do app via shared_preferences (armazenamento interno
/// do celular). Por isso o app funciona 100% offline.
class LocalStorageService {
  static const String _chaveClientes = 'lista_clientes';
  static const String _chaveProdutos = 'lista_produtos';
  static const String _chavePedidos = 'lista_pedidos';
  static const String _chaveSessao = 'cliente_logado_id';
  static const String _chaveProdutosSemente = 'produtos_semente_criada';

  // Clientes

  static Future<void> salvarClientes(List<Cliente> lista) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveClientes, Cliente.encode(lista));
  }

  static Future<List<Cliente>> carregarClientes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(_chaveClientes);
    if (json == null) return [];
    return Cliente.decode(json);
  }

  // Produtos

  static Future<void> salvarProdutos(List<Produto> lista) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveProdutos, Produto.encode(lista));
  }

  static Future<List<Produto>> carregarProdutos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(_chaveProdutos);
    if (json == null) return [];
    return Produto.decode(json);
  }

  /// Cria produtos de exemplo na primeira execução, para facilitar testar o app.
  static Future<void> criarProdutosDeExemploSeNecessario() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool jaCriou = prefs.getBool(_chaveProdutosSemente) ?? false;
    if (jaCriou) return;

    final produtosExemplo = [
      Produto(id: 1, nome: 'Sofá 3 lugares', descricao: 'Tecido linho, confortável', preco: 1899.90),
      Produto(id: 2, nome: 'Mesa de jantar', descricao: 'Madeira maciça, 6 lugares', preco: 1299.00),
      Produto(id: 3, nome: 'Cadeira estofada', descricao: 'Base de madeira, tecido suede', preco: 249.90),
      Produto(id: 4, nome: 'Guarda-roupa', descricao: '6 portas, espelho incluso', preco: 2199.00),
      Produto(id: 5, nome: 'Rack para TV', descricao: 'Até 65", design moderno', preco: 599.90),
    ];

    await salvarProdutos(produtosExemplo);
    await prefs.setBool(_chaveProdutosSemente, true);
  }

  // Pedidos

  static Future<void> salvarPedidos(List<Pedido> lista) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chavePedidos, Pedido.encode(lista));
  }

  static Future<List<Pedido>> carregarPedidos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(_chavePedidos);
    if (json == null) return [];
    return Pedido.decode(json);
  }

  // Sessão do cliente

  static Future<void> salvarSessao(int clienteId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveSessao, clienteId);
  }

  static Future<int?> carregarSessao() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_chaveSessao);
  }

  static Future<void> limparSessao() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveSessao);
  }
}
