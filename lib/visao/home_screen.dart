import 'package:flutter/material.dart';
import '../modelo/classes/item_pedido.dart';
import 'carrinho/carrinho_tab.dart';
import 'cliente/perfil_tab.dart';
import 'cores_app.dart';
import 'pedido/pedidos_tab.dart';
import 'produto/catalogo_tab.dart';

/// Tela principal após o login: bottom navigation trocando entre as
/// 4 abas. O carrinho fica guardado aqui (em memória), pois é
/// compartilhado entre a aba de Catálogo e a de Carrinho.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _abaAtual = 0;
  final List<ItemPedido> _carrinho = [];

  // Muda a cada compra finalizada, para forçar a PedidosTab a
  // recarregar (o IndexedStack mantém as abas vivas, então sem isso
  // o pedido novo só apareceria depois de reiniciar o app).
  int _versaoPedidos = 0;

  void _adicionarAoCarrinho(ItemPedido novoItem) {
    setState(() {
      final indexExistente =
          _carrinho.indexWhere((i) => i.produtoId == novoItem.produtoId);
      if (indexExistente != -1) {
        final atual = _carrinho[indexExistente];
        _carrinho[indexExistente] =
            atual.copiarComQuantidade(atual.quantidade + novoItem.quantidade);
      } else {
        _carrinho.add(novoItem);
      }
    });
  }

  void _removerDoCarrinho(int produtoId) {
    setState(() => _carrinho.removeWhere((i) => i.produtoId == produtoId));
  }

  void _alterarQuantidadeCarrinho(int produtoId, int novaQuantidade) {
    setState(() {
      if (novaQuantidade <= 0) {
        _carrinho.removeWhere((i) => i.produtoId == produtoId);
        return;
      }
      final index = _carrinho.indexWhere((i) => i.produtoId == produtoId);
      if (index != -1) {
        _carrinho[index] = _carrinho[index].copiarComQuantidade(novaQuantidade);
      }
    });
  }

  void _limparCarrinho() {
    setState(() {
      _carrinho.clear();
      _versaoPedidos++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final abas = [
      CatalogoTab(onAdicionarAoCarrinho: _adicionarAoCarrinho),
      CarrinhoTab(
        itens: _carrinho,
        onAlterarQuantidade: _alterarQuantidadeCarrinho,
        onRemover: _removerDoCarrinho,
        onCompraFinalizada: _limparCarrinho,
      ),
      PedidosTab(key: ValueKey(_versaoPedidos)),
      const PerfilTab(),
    ];

    return Scaffold(
      backgroundColor: corBege,
      body: IndexedStack(index: _abaAtual, children: abas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaAtual,
        onDestinationSelected: (index) => setState(() {
          _abaAtual = index;
          if (index == 2) _versaoPedidos++;
        }),
        backgroundColor: Colors.white,
        indicatorColor: corBegeClaro,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: corMarromEscuro),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _carrinho.isNotEmpty,
              label: Text('${_carrinho.length}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: const Icon(Icons.shopping_cart, color: corMarromEscuro),
            label: 'Carrinho',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: corMarromEscuro),
            label: 'Pedidos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: corMarromEscuro),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
