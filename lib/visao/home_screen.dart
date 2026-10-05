import 'package:flutter/material.dart';
import '../modelo/classes/item_pedido.dart';
import '../controle/carrinho_controller.dart';
import '../modelo/api_service.dart';
import 'carrinho/carrinho_tab.dart';
import 'cliente/perfil_tab.dart';
import 'cores_app.dart';
import 'pedido/pedidos_tab.dart';
import 'produto/catalogo_tab.dart';

/// Tela principal após o login: bottom navigation trocando entre as
/// 4 abas. A lista do carrinho fica aqui, pois é compartilhada entre a aba
/// de Catálogo e a de Carrinho. Quem guarda o carrinho de verdade é o servidor
/// (API): cada mudança é enviada para lá e depois a lista é recarregada.
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

  @override
  void initState() {
    super.initState();
    _carregarCarrinho();
  }

  void _avisar(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  // Busca o carrinho do cliente na API
  Future<void> _carregarCarrinho() async {
    try {
      final resultado = await CarrinhoController.listar();
      if (!mounted) return;
      setState(() {
        _carrinho
          ..clear()
          ..addAll(resultado.lista);
      });
    } on ApiException catch (erro) {
      _avisar(erro.mensagem);
    }
  }

  // Devolve true se o servidor aceitou (o catálogo usa isso para avisar o cliente)
  Future<bool> _adicionarAoCarrinho(ItemPedido novoItem) async {
    try {
      await CarrinhoController.adicionar(novoItem.produtoId, novoItem.quantidade);
    } on ApiException catch (erro) {
      _avisar(erro.mensagem);
      return false;
    }
    await _carregarCarrinho();
    return true;
  }

  Future<void> _removerDoCarrinho(int produtoId) async {
    try {
      await CarrinhoController.remover(produtoId);
    } on ApiException catch (erro) {
      _avisar(erro.mensagem);
      return;
    }
    await _carregarCarrinho();
  }

  Future<void> _alterarQuantidadeCarrinho(int produtoId, int novaQuantidade) async {
    try {
      if (novaQuantidade <= 0) {
        await CarrinhoController.remover(produtoId);
      } else {
        await CarrinhoController.alterarQuantidade(produtoId, novaQuantidade);
      }
    } on ApiException catch (erro) {
      _avisar(erro.mensagem);
      return;
    }
    await _carregarCarrinho();
  }

  // Chamado depois que o servidor já transformou o carrinho em pedidos
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
        onDestinationSelected: (index) {
          setState(() {
            _abaAtual = index;
            if (index == 2) _versaoPedidos++;
          });
          // Ao abrir o carrinho, busca de novo: ele pode ter mudado pelo site
          if (index == 1) _carregarCarrinho();
        },
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
