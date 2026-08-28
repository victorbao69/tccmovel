import 'package:flutter/material.dart';
import '../../controle/pedido_controller.dart';
import '../../modelo/classes/pedido.dart';
import '../cores_app.dart';

class PedidoDetalhesScreen extends StatefulWidget {
  final Pedido pedido;

  const PedidoDetalhesScreen({super.key, required this.pedido});

  @override
  State<PedidoDetalhesScreen> createState() => _PedidoDetalhesScreenState();
}

class _PedidoDetalhesScreenState extends State<PedidoDetalhesScreen> {
  late Pedido _pedido;

  @override
  void initState() {
    super.initState();
    _pedido = widget.pedido;
  }

  Future<void> _alterarQuantidade(int produtoId, int novaQuantidade) async {
    if (novaQuantidade <= 0) return;
    await PedidoController.atualizarQuantidadeItem(
      pedidoId: _pedido.id,
      produtoId: produtoId,
      novaQuantidade: novaQuantidade,
    );
    setState(() {
      _pedido = _pedido.copiarComItens(_pedido.itens.map((item) {
        return item.produtoId == produtoId ? item.copiarComQuantidade(novaQuantidade) : item;
      }).toList());
    });
  }

  Future<void> _excluirPedido() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir pedido?'),
        content: Text('Deseja excluir o pedido #${_pedido.id}? Essa ação não pode ser desfeita.'),
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
      await PedidoController.excluirPedido(_pedido.id);
      if (mounted) Navigator.pop(context);
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
        title: Text('Pedido #${_pedido.id}', style: const TextStyle(color: corBegeClaro, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline, color: corBegeClaro), onPressed: _excluirPedido),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _pedido.itens.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final item = _pedido.itens[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: corCinzaBorda),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.nomeProduto, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('R\$ ${item.precoUnitario.toStringAsFixed(2).replaceAll('.', ',')} cada',
                                style: const TextStyle(fontSize: 11, color: corCinzaTexto)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20, color: corMarromEscuro),
                        onPressed: () => _alterarQuantidade(item.produtoId, item.quantidade - 1),
                      ),
                      Text('${item.quantidade}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 20, color: corMarromEscuro),
                        onPressed: () => _alterarQuantidade(item.produtoId, item.quantidade + 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 14, color: corCinzaTexto)),
                Text('R\$ ${_pedido.total.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: corMarromEscuro)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
