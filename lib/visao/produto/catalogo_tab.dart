import 'package:flutter/material.dart';
import '../../controle/produto_controller.dart';
import '../../modelo/classes/item_pedido.dart';
import '../../modelo/classes/produto.dart';
import '../cores_app.dart';
import 'produto_detalhes_screen.dart';
import 'produto_form_screen.dart';

class CatalogoTab extends StatefulWidget {
  final void Function(ItemPedido) onAdicionarAoCarrinho;

  const CatalogoTab({super.key, required this.onAdicionarAoCarrinho});

  @override
  State<CatalogoTab> createState() => _CatalogoTabState();
}

class _CatalogoTabState extends State<CatalogoTab> {
  List<Produto> _produtos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() => _carregando = true);
    final lista = await ProdutoController.listar();
    if (!mounted) return;
    setState(() {
      _produtos = lista;
      _carregando = false;
    });
  }

  Future<void> _abrirDetalhes(Produto produto) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProdutoDetalhesScreen(produto: produto),
      ),
    );

    if (resultado is Map && resultado['adicionarAoCarrinho'] == true) {
      widget.onAdicionarAoCarrinho(ItemPedido(
        produtoId: produto.id,
        nomeProduto: produto.nome,
        precoUnitario: produto.preco,
        quantidade: 1,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${produto.nome} adicionado ao carrinho!')),
        );
      }
    }
    _carregarProdutos();
  }

  Future<void> _abrirNovoProduto() async {
    final salvou = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProdutoFormScreen()),
    );
    if (salvou == true) _carregarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corBege,
      appBar: AppBar(
        backgroundColor: corMarromEscuro,
        elevation: 0,
        title: const Text('Catálogo', style: TextStyle(color: corBegeClaro, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: corBegeClaro),
            tooltip: 'Novo produto',
            onPressed: _abrirNovoProduto,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _produtos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 48, color: corCinzaBorda),
                      const SizedBox(height: 12),
                      const Text('Nenhum produto no catálogo ainda', style: TextStyle(color: corCinzaTexto)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _abrirNovoProduto,
                        style: ElevatedButton.styleFrom(backgroundColor: corMarromEscuro),
                        child: const Text('Cadastrar produto', style: TextStyle(color: corBegeClaro)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregarProdutos,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _produtos.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 260,
                    ),
                    itemBuilder: (_, i) {
                      final produto = _produtos[i];
                      return _CartaoProduto(
                        produto: produto,
                        onDetalhes: () => _abrirDetalhes(produto),
                        onAdicionar: () {
                          widget.onAdicionarAoCarrinho(ItemPedido(
                            produtoId: produto.id,
                            nomeProduto: produto.nome,
                            precoUnitario: produto.preco,
                            quantidade: 1,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${produto.nome} adicionado!'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _CartaoProduto extends StatelessWidget {
  final Produto produto;
  final VoidCallback onDetalhes;
  final VoidCallback onAdicionar;

  const _CartaoProduto({
    required this.produto,
    required this.onDetalhes,
    required this.onAdicionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: corCinzaBorda),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(produto.nome,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: corTextoEscuro),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (produto.favorito) const Icon(Icons.favorite, size: 14, color: corMarromEscuro),
              ],
            ),
            const SizedBox(height: 2),
            Text(produto.descricao,
                style: const TextStyle(fontSize: 11, color: corCinzaTexto),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(
              'R\$ ${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: corMarromEscuro),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDetalhes,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      side: const BorderSide(color: corCinzaBorda),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Detalhes', style: TextStyle(fontSize: 11, color: Color(0xFF5F5E5A))),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAdicionar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corMarromEscuro,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('+ Add', style: TextStyle(fontSize: 11, color: corBegeClaro)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
