import 'package:flutter/material.dart';
import '../../controle/produto_controller.dart';
import '../../modelo/classes/produto.dart';
import '../cores_app.dart';
import 'produto_form_screen.dart';

/// Tela cheia com os detalhes do produto (editar/excluir/favoritar).
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

  Future<void> _editar() async {
    final salvou = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProdutoFormScreen(produtoParaEditar: _produto)),
    );
    if (salvou == true) {
      final atualizado = await ProdutoController.buscarPorId(_produto.id);
      if (atualizado != null && mounted) {
        setState(() => _produto = atualizado);
      }
    }
  }

  Future<void> _excluir() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text('Tem certeza que deseja excluir "${_produto.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmou == true) {
      await ProdutoController.excluir(_produto.id);
      if (mounted) Navigator.pop(context, {'excluido': true});
    }
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
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: corBegeClaro),
            onPressed: _editar,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: corBegeClaro),
            onPressed: _excluir,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: corBegeClaro,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.inventory_2_outlined, size: 56, color: corMarromEscuro),
              ),
            ),
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
