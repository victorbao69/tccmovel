import 'package:flutter/material.dart';
import '../../controle/cliente_controller.dart';
import '../../modelo/classes/cliente.dart';
import '../cores_app.dart';
import '../home_screen.dart';

/// Tela usada tanto para cadastro (clienteParaEditar nulo) quanto
/// para edição do perfil do cliente logado.
class CadastroClienteScreen extends StatefulWidget {
  final Cliente? clienteParaEditar;

  const CadastroClienteScreen({super.key, this.clienteParaEditar});

  bool get ehEdicao => clienteParaEditar != null;

  @override
  State<CadastroClienteScreen> createState() => _CadastroClienteScreenState();
}

class _CadastroClienteScreenState extends State<CadastroClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _senhaController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _enderecoController;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.clienteParaEditar;
    _nomeController = TextEditingController(text: c?.nome ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _senhaController = TextEditingController(text: c?.senha ?? '');
    _telefoneController = TextEditingController(text: c?.telefone ?? '');
    _enderecoController = TextEditingController(text: c?.endereco ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    if (widget.ehEdicao) {
      final clienteAtualizado = Cliente(
        id: widget.clienteParaEditar!.id,
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
        telefone: _telefoneController.text.trim(),
        endereco: _enderecoController.text.trim(),
      );
      await ClienteController.atualizar(clienteAtualizado);

      if (!mounted) return;
      setState(() => _carregando = false);
      Navigator.pop(context, clienteAtualizado);
      return;
    }

    final novoCliente = await ClienteController.cadastrar(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      senha: _senhaController.text,
      telefone: _telefoneController.text.trim(),
      endereco: _enderecoController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _carregando = false);

    if (novoCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Já existe uma conta com esse e-mail.')),
      );
      return;
    }

    await ClienteController.login(novoCliente.email, novoCliente.senha);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corBege,
      appBar: AppBar(
        backgroundColor: corMarromEscuro,
        elevation: 0,
        title: Text(
          widget.ehEdicao ? 'Editar perfil' : 'Criar conta',
          style: const TextStyle(color: corBegeClaro, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: corBegeClaro),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _campo('Nome completo', _nomeController, obrigatorio: true),
              const SizedBox(height: 14),
              _campo('E-mail', _emailController,
                  obrigatorio: true, tipoTeclado: TextInputType.emailAddress, validarEmail: true),
              const SizedBox(height: 14),
              _campo('Senha', _senhaController,
                  obrigatorio: true, ocultar: true, tamanhoMinimo: 6),
              const SizedBox(height: 14),
              _campo('Telefone', _telefoneController, tipoTeclado: TextInputType.phone),
              const SizedBox(height: 14),
              _campo('Endereço', _enderecoController),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corMarromEscuro,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: corBegeClaro),
                        )
                      : Text(
                          widget.ehEdicao ? 'Salvar alterações' : 'Cadastrar',
                          style: const TextStyle(fontSize: 15, color: corBegeClaro),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(
    String rotulo,
    TextEditingController controller, {
    bool obrigatorio = false,
    bool ocultar = false,
    bool validarEmail = false,
    int? tamanhoMinimo,
    TextInputType tipoTeclado = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: const TextStyle(fontSize: 12, color: corCinzaTexto, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: ocultar,
          keyboardType: tipoTeclado,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: corCinzaBorda),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: corCinzaBorda),
            ),
          ),
          validator: (valor) {
            if (obrigatorio && (valor == null || valor.trim().isEmpty)) {
              return 'Campo obrigatório';
            }
            if (validarEmail && valor != null && valor.isNotEmpty && !valor.contains('@')) {
              return 'E-mail inválido';
            }
            if (tamanhoMinimo != null && valor != null && valor.isNotEmpty && valor.length < tamanhoMinimo) {
              return 'Mínimo de $tamanhoMinimo caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }
}
