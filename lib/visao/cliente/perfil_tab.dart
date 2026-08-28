import 'package:flutter/material.dart';
import '../../controle/cliente_controller.dart';
import '../../modelo/classes/cliente.dart';
import '../cores_app.dart';
import 'cadastro_cliente_screen.dart';
import 'login_screen.dart';

class PerfilTab extends StatefulWidget {
  const PerfilTab({super.key});

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  Cliente? _cliente;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarCliente();
  }

  Future<void> _carregarCliente() async {
    setState(() => _carregando = true);
    final cliente = await ClienteController.clienteLogado();
    if (!mounted) return;
    setState(() {
      _cliente = cliente;
      _carregando = false;
    });
  }

  Future<void> _editarPerfil() async {
    if (_cliente == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CadastroClienteScreen(clienteParaEditar: _cliente)),
    );
    _carregarCliente();
  }

  Future<void> _sairDaConta() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sair')),
        ],
      ),
    );
    if (confirmou != true) return;

    await ClienteController.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (rota) => false,
    );
  }

  Future<void> _excluirConta() async {
    if (_cliente == null) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Essa ação é permanente: sua conta e todos os seus pedidos serão excluídos. Deseja continuar?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir conta', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await ClienteController.excluirConta(_cliente!.id);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (rota) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corBege,
      appBar: AppBar(
        backgroundColor: corMarromEscuro,
        elevation: 0,
        title: const Text('Perfil', style: TextStyle(color: corBegeClaro, fontSize: 16)),
        centerTitle: true,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _cliente == null
              ? const Center(child: Text('Nenhum cliente logado', style: TextStyle(color: corCinzaTexto)))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: const BoxDecoration(color: corBegeClaro, shape: BoxShape.circle),
                            child: const Icon(Icons.person, size: 40, color: corMarromEscuro),
                          ),
                          const SizedBox(height: 12),
                          Text(_cliente!.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          Text(_cliente!.email, style: const TextStyle(fontSize: 13, color: corCinzaTexto)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _linhaInfo('Telefone', _cliente!.telefone.isEmpty ? '-' : _cliente!.telefone),
                    _linhaInfo('Endereço', _cliente!.endereco.isEmpty ? '-' : _cliente!.endereco),
                    const SizedBox(height: 28),
                    _botao('Editar perfil', Icons.edit_outlined, _editarPerfil),
                    const SizedBox(height: 12),
                    _botao('Sair (logout)', Icons.logout, _sairDaConta),
                    const SizedBox(height: 12),
                    _botao('Excluir conta', Icons.delete_forever_outlined, _excluirConta, perigo: true),
                  ],
                ),
    );
  }

  Widget _linhaInfo(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(rotulo, style: const TextStyle(fontSize: 13, color: corCinzaTexto))),
          Expanded(child: Text(valor, style: const TextStyle(fontSize: 13, color: corTextoEscuro))),
        ],
      ),
    );
  }

  Widget _botao(String texto, IconData icone, VoidCallback onPressed, {bool perigo = false}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icone, size: 18, color: perigo ? Colors.red : corMarromEscuro),
        label: Text(texto, style: TextStyle(fontSize: 14, color: perigo ? Colors.red : corTextoEscuro)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 13),
          side: BorderSide(color: perigo ? Colors.red.withOpacity(0.4) : corCinzaBorda),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
