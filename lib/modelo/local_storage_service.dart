import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'classes/cliente.dart';
import 'classes/item_pedido.dart';
import 'classes/produto.dart';
import 'classes/pedido.dart';


class LocalStorageService {
  static const String _chaveToken = 'api_token';
  static const String _chaveCliente = 'cliente_logado';
  static const String _chaveProdutos = 'cache_produtos';
  static const String _chavePedidos = 'cache_pedidos';
  static const String _chaveFavoritos = 'produtos_favoritos';
  static const String _chaveCarrinho = 'carrinho_itens';

  // Token de login

  static Future<void> salvarToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveToken, token);
  }

  static Future<String?> carregarToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveToken);
  }

  // Cliente logado (cópia dos dados do perfil)

  static Future<void> salvarCliente(Cliente cliente) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveCliente, json.encode(cliente.toMap()));
  }

  static Future<Cliente?> carregarCliente() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? texto = prefs.getString(_chaveCliente);
    if (texto == null) return null;
    return Cliente.fromMap(json.decode(texto));
  }

  /// Logout / conta excluída: apaga token, perfil e pedidos salvos no aparelho.
  static Future<void> limparSessao() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveToken);
    await prefs.remove(_chaveCliente);
    await prefs.remove(_chavePedidos);
    await prefs.remove(_chaveCarrinho);
  }

  // Cópia dos produtos

  static Future<void> salvarProdutos(List<Produto> lista) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveProdutos, Produto.encode(lista));
  }

  static Future<List<Produto>> carregarProdutos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? texto = prefs.getString(_chaveProdutos);
    if (texto == null) return [];
    return Produto.decode(texto);
  }

  // Cópia dos pedidos

  static Future<void> salvarPedidos(List<Pedido> lista) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chavePedidos, Pedido.encode(lista));
  }

  static Future<List<Pedido>> carregarPedidos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? texto = prefs.getString(_chavePedidos);
    if (texto == null) return [];
    return Pedido.decode(texto);
  }

  // Carrinho (fica só no aparelho: o servidor só recebe quando a compra é finalizada)

  static Future<void> salvarCarrinho(List<ItemPedido> itens) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveCarrinho, ItemPedido.encode(itens));
  }

  static Future<List<ItemPedido>> carregarCarrinho() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? texto = prefs.getString(_chaveCarrinho);
    if (texto == null) return [];
    return ItemPedido.decode(texto);
  }

  // Favoritos (só existem no aparelho, o site não tem favoritos)

  static Future<void> salvarFavoritos(List<int> ids) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_chaveFavoritos, ids.map((id) => id.toString()).toList());
  }

  static Future<List<int>> carregarFavoritos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> ids = prefs.getStringList(_chaveFavoritos) ?? [];
    return ids.map((id) => int.tryParse(id) ?? 0).toList();
  }
}
