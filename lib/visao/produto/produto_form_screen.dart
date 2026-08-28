import 'package:flutter/material.dart';
import '../../controle/produto_controller.dart';
import '../../modelo/classes/produto.dart';
import '../cores_app.dart';

class ProdutoFormScreen extends StatefulWidget {
  final Produto? produtoParaEditar;

  const ProdutoFormScreen({super.key, this.produtoParaEditar});

  bool get ehEdicao => produtoParaEditar != null;

  @override
  State<ProdutoFormScreen> createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _precoController;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    final p = widget.produtoParaEditar;
    _nomeController = TextEditingController(text: p?.nome ?? '');
    _descricaoController = TextEditingController(text: p?.descricao ?? '');
    _precoController = TextEditingController(text: p != null ? p.preco.toStringAsFixed(2) : '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    final preco = double.parse(_precoController.text.replaceAll(',', '.'));

    if (widget.ehEdicao) {
      await ProdutoController.atualizar(widget.produtoParaEditar!.copiarCom(
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        preco: preco,
      ));
    } else {
      await ProdutoController.inserir(
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        preco: preco,
      );
    }

    if (!mounted) return;
    setState(() => _carregando = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corBege,
      appBar: AppBar(
        backgroundColor: corMarromEscuro,
        elevation: 0,
        iconTheme: const IconThemeData(color: corBegeClaro),
        title: Text(widget.ehEdicao ? 'Editar produto' : 'Novo produto',
            style: const TextStyle(color: corBegeClaro, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _campo('Nome', _nomeController),
              const SizedBox(height: 14),
              _campo('Descrição', _descricaoController, linhas: 3),
              const SizedBox(height: 14),
              _campo('Preço (R\$)', _precoController, tipoTeclado: const TextInputType.numberWithOptions(decimal: true), ehPreco: true),
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
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: corBegeClaro))
                      : Text(widget.ehEdicao ? 'Salvar alterações' : 'Cadastrar produto',
                          style: const TextStyle(fontSize: 15, color: corBegeClaro)),
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
    int linhas = 1,
    bool ehPreco = false,
    TextInputType tipoTeclado = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: const TextStyle(fontSize: 12, color: corCinzaTexto, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: linhas,
          keyboardType: tipoTeclado,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: corCinzaBorda)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: corCinzaBorda)),
          ),
          validator: (valor) {
            if (valor == null || valor.trim().isEmpty) return 'Campo obrigatório';
            if (ehPreco) {
              final numero = double.tryParse(valor.replaceAll(',', '.'));
              if (numero == null || numero <= 0) return 'Informe um preço válido';
            }
            return null;
          },
        ),
      ],
    );
  }
}
