import 'package:flutter/material.dart';
import '../controle/cliente_controller.dart';
import '../modelo/local_storage_service.dart';
import 'cliente/login_screen.dart';
import 'cores_app.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _prepararEDecidirRota();
  }

  Future<void> _prepararEDecidirRota() async {
    await LocalStorageService.criarProdutosDeExemploSeNecessario();

    // Pequena espera para a splash aparecer na tela.
    await Future.delayed(const Duration(milliseconds: 900));

    final cliente = await ClienteController.clienteLogado();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => cliente != null ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corMarromEscuro,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: corBegeClaro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: corMarromEscuro, width: 4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'PlanHome',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: corBegeClaro,
                fontFamily: 'Georgia',
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Móveis & Decoração',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Color(0xFFD4B896),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: corBegeClaro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
