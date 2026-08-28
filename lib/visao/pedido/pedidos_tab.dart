import 'package:flutter/material.dart';
import '../../controle/cliente_controller.dart';
import '../../controle/pedido_controller.dart';
import '../../modelo/classes/pedido.dart';
import '../cores_app.dart';
import 'pedido_detalhes_screen.dart';

class PedidosTab extends StatefulWidget {
  const PedidosTab({super.key});

  @override
  State<PedidosTab> createState() => _PedidosTabState();
}

class _PedidosTabState extends State<PedidosTab> {
  List<Pedido> _pedidos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  Future<void> _carregarPedidos() async {
    setState(() => _carregando = true);
    final cliente = await ClienteController.clienteLogado();
    if (cliente == null) {
      if (mounted) setState(() => _carregando = false);
      return;
    }
    final lista = await PedidoController.listarPedidosDoCliente(cliente.id);
    if (!mounted) return;
    setState(() {
      _pedidos = lista;
      _carregando = false;
    });
  }

  String _formatarData(String isoData) {
    final data = DateTime.tryParse(isoData);
    if (data == null) return '';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corBege,
      appBar: AppBar(
        backgroundColor: corMarromEscuro,
        elevation: 0,
        title: const Text('Meus pedidos', style: TextStyle(color: corBegeClaro, fontSize: 16)),
        centerTitle: true,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _pedidos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: corCinzaBorda),
                      SizedBox(height: 12),
                      Text('Você ainda não fez nenhum pedido', style: TextStyle(color: corCinzaTexto)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregarPedidos,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pedidos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final pedido = _pedidos[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PedidoDetalhesScreen(pedido: pedido)),
                          );
                          _carregarPedidos();
                        },
                        child: Container(
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
                                    Text('Pedido #${pedido.id}',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: corTextoEscuro)),
                                    const SizedBox(height: 4),
                                    Text(_formatarData(pedido.data), style: const TextStyle(fontSize: 12, color: corCinzaTexto)),
                                    const SizedBox(height: 2),
                                    Text('${pedido.itens.length} item(ns)', style: const TextStyle(fontSize: 12, color: corCinzaTexto)),
                                  ],
                                ),
                              ),
                              Text(
                                'R\$ ${pedido.total.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: corMarromEscuro),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, color: corCinzaTexto),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
