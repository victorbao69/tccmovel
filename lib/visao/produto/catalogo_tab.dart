import 'package:flutter/material.dart';
import '../../controle/produto_controller.dart';
import '../../modelo/api_service.dart';
import '../../modelo/classes/item_pedido.dart';
import '../../modelo/classes/produto.dart';
import '../cores_app.dart';
import 'imagem_produto.dart';
import 'produto_detalhes_screen.dart';

class CatalogoTab extends StatefulWidget {
  final void Function(ItemPedido) onAdicionarAoCarrinho;

  const CatalogoTab({super.key, required this.onAdicionarAoCarrinho});

  @override
  State<CatalogoTab> createState() => _CatalogoTabState();
}

class _CatalogoTabState extends State<CatalogoTab> {
  List<Produto> _produtos = [];
  bool _carregando = true;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() => _carregando = true);
    try {
      final resultado = await ProdutoController.listar();
      if (!mounted) return;
      setState(() {
        _produtos = resultado.lista;
        _offline = resultado.offline;
        _carregando = false;
      });
    } on ApiException catch (erro) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro.mensagem)),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corBege,
      appBar: AppBar(
        backgroundColor: corMarromEscuro,
        elevation: 0,
        title: const Text('Catálogo', style: TextStyle(color: corBegeClaro, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_offline) const _AvisoOffline(),
          Expanded(child: _conteudo()),
        ],
      ),
    );
  }

  Widget _conteudo() {
    return _carregando
          ? const Center(child: CircularProgressIndicator())
          : _produtos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 48, color: corCinzaBorda),
                      const SizedBox(height: 12),
                      const Text('Nenhum produto disponível no momento', style: TextStyle(color: corCinzaTexto)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _carregarProdutos,
                        style: ElevatedButton.styleFrom(backgroundColor: corMarromEscuro),
                        child: const Text('Tentar de novo', style: TextStyle(color: corBegeClaro)),
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
                );
  }
}

/// Faixa que aparece quando o catálogo está vindo da cópia salva no aparelho.
class _AvisoOffline extends StatelessWidget {
  const _AvisoOffline();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: corBegeClaro,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Text(
        'Sem conexão: mostrando os últimos produtos salvos no aparelho.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: corMarromEscuro),
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
            ImagemProduto(url: produto.imagemUrl, altura: 90),
            const SizedBox(height: 8),
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
