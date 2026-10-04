import 'package:flutter/material.dart';
import '../../controle/produto_controller.dart';
import '../../modelo/classes/produto.dart';
import '../cores_app.dart';
import 'imagem_produto.dart';

/// Tela cheia com os detalhes do produto (favoritar e adicionar ao carrinho).
class ProdutoDetalhesScreen extends StatefulWidget {
  final Produto produto;

  const ProdutoDetalhesScreen({super.key, required this.produto});

  @override
  State<ProdutoDetalhesScreen> createState() => _ProdutoDetalhesScreenState();
}

class _ProdutoDetalhesScreenState extends State<ProdutoDetalhesScreen> {
  late Produto _produto;

  @override
  void initState() {
    super.initState();
    _produto = widget.produto;
  }

  Future<void> _favoritar() async {
    await ProdutoController.favoritar(_produto);
    setState(() => _produto = _produto.copiarCom(favorito: !_produto.favorito));
  }

  void _adicionarAoCarrinho() {
    Navigator.pop(context, {'adicionarAoCarrinho': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corBege,
      appBar: AppBar(
        backgroundColor: corMarromEscuro,
        elevation: 0,
        iconTheme: const IconThemeData(color: corBegeClaro),
        title: const Text('Detalhes do produto', style: TextStyle(color: corBegeClaro, fontSize: 15)),
        actions: [
          IconButton(
            icon: Icon(_produto.favorito ? Icons.favorite : Icons.favorite_border, color: corBegeClaro),
            onPressed: _favoritar,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImagemProduto(url: _produto.imagemUrl, altura: 200),
            const SizedBox(height: 20),
            Text(_produto.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: corTextoEscuro)),
            const SizedBox(height: 8),
            Text(_produto.descricao, style: const TextStyle(fontSize: 14, color: corCinzaTexto, height: 1.5)),
            const SizedBox(height: 16),
            Text(
              'R\$ ${_produto.preco.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: corMarromEscuro),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _adicionarAoCarrinho,
                style: ElevatedButton.styleFrom(
                  backgroundColor: corMarromEscuro,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Adicionar ao carrinho', style: TextStyle(fontSize: 14, color: corBegeClaro)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
