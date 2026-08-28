import 'package:flutter/material.dart';
import '../../controle/cliente_controller.dart';
import '../cores_app.dart';
import '../home_screen.dart';
import 'cadastro_cliente_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    final cliente = await ClienteController.login(
      _emailController.text.trim(),
      _senhaController.text,
    );
    if (!mounted) return;
    setState(() => _carregando = false);

    if (cliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail ou senha inválidos.')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _irParaCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastroClienteScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corBege,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [corMarromEscuro, corMarromMedio],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 36),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo\nde volta.',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: corBegeClaro,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Acesse sua conta para continuar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFFD4B896),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _rotulo('E-MAIL'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _decoracaoCampo('seu@email.com', Icons.mail_outline_rounded),
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'Informe seu e-mail';
                          }
                          if (!valor.contains('@')) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _rotulo('SENHA'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: _decoracaoCampo('••••••••', Icons.lock_outline_rounded),
                        validator: (valor) {
                          if (valor == null || valor.isEmpty) {
                            return 'Informe sua senha';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _carregando ? null : _entrar,
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
                              : const Text('Entrar', style: TextStyle(fontSize: 15, color: corBegeClaro)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: _irParaCadastro,
                          child: const Text(
                            'Não tem conta? Cadastre-se',
                            style: TextStyle(color: corMarromEscuro),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rotulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: corCinzaTexto, letterSpacing: 0.8),
    );
  }

  InputDecoration _decoracaoCampo(String dica, IconData icone) {
    return InputDecoration(
      hintText: dica,
      prefixIcon: Icon(icone, size: 18, color: corCinzaBorda),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: corCinzaBorda),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: corCinzaBorda),
      ),
    );
  }
}
