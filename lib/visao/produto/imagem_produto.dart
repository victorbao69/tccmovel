import 'package:flutter/material.dart';
import '../cores_app.dart';

/// Mostra a imagem do produto (vinda do site). Se o produto não tem imagem
/// ou ela não carrega (sem internet), mostra um ícone no lugar.
class ImagemProduto extends StatelessWidget {
  final String url;
  final double altura;

  const ImagemProduto({super.key, required this.url, required this.altura});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: double.infinity,
        height: altura,
        child: url.isEmpty
            ? _icone()
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _icone(),
              ),
      ),
    );
  }

  Widget _icone() {
    return Container(
      color: corBegeClaro,
      child: const Center(
        child: Icon(Icons.inventory_2_outlined, size: 40, color: corMarromEscuro),
      ),
    );
  }
}
