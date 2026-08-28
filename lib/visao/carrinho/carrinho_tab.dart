import 'package:flutter/material.dart';
import '../../controle/cliente_controller.dart';
import '../../controle/pedido_controller.dart';
import '../../modelo/classes/item_pedido.dart';
import '../cores_app.dart';

class CarrinhoTab extends StatefulWidget {
  final List<ItemPedido> itens;
  final void Function(int produtoId, int novaQuantidade) onAlterarQuantidade;
  final void Function(int produtoId) onRemover;
  final VoidCallback onCompraFinalizada;

  const CarrinhoTab({
    super.key,
    required this.itens,
    required this.onAlterarQuantidade,
    required this.onRemover,
    required this.onCompraFinalizada,
  });

  @override
  State<CarrinhoTab> createState() => _CarrinhoTabState();
}

class _CarrinhoTabState extends State<CarrinhoTab> {
  bool _finalizando = false;

  double get _total => widget.itens.fold(0.0, (soma, item) => soma + item.subtotal);

  Future<void> _finalizarCompra() async {
    setState(() => _finalizando = true);
    final cliente = await ClienteController.clienteLogado();

    if (cliente == null) {
      if (mounted) setState(() => _finalizando = false);
      return;
    }

    await PedidoController.criarPedido(clienteId: cliente.id, itens: List.of(widget.itens));
    widget.onCompraFinalizada();

    if (!mounted) return;
    setState(() => _finalizando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido realizado com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corBege,
      appBar: AppBar(
        backgroundColor: corMarromEscuro,
        elevation: 0,
        title: const Text('Carrinho', style: TextStyle(color: corBegeClaro, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.itens.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 48, color: corCinzaBorda),
                        SizedBox(height: 12),
                        Text('Seu carrinho está vazio', style: TextStyle(color: corCinzaTexto)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.itens.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final item = widget.itens[i];
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
                                  Text(item.nomeProduto,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: corTextoEscuro)),
                                  const SizedBox(height: 4),
                                  Text('R\$ ${item.precoUnitario.toStringAsFixed(2).replaceAll('.', ',')} cada',
                                      style: const TextStyle(fontSize: 11, color: corCinzaTexto)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20, color: corMarromEscuro),
                              onPressed: () => widget.onAlterarQuantidade(item.produtoId, item.quantidade - 1),
                            ),
                            Text('${item.quantidade}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20, color: corMarromEscuro),
                              onPressed: () => widget.onAlterarQuantidade(item.produtoId, item.quantidade + 1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              onPressed: () => widget.onRemover(item.produtoId),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 13, color: corCinzaTexto)),
                    Text('R\$ ${_total.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: corMarromEscuro)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (widget.itens.isEmpty || _finalizando) ? null : _finalizarCompra,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corMarromEscuro,
                      disabledBackgroundColor: const Color(0xFFB4967A),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _finalizando
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: corBegeClaro))
                        : const Text('Finalizar compra', style: TextStyle(fontSize: 15, color: corBegeClaro)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
