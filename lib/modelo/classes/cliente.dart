import 'dart:convert';

/// Representa um cliente: dados de cadastro e login.
class Cliente {
  final int id;
  final String nome;
  final String email;
  final String senha;
  final String telefone;
  final String endereco;

  Cliente({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.telefone,
    required this.endereco,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'telefone': telefone,
      'endereco': endereco,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] ?? 0,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      senha: map['senha'] ?? '',
      telefone: map['telefone'] ?? '',
      endereco: map['endereco'] ?? '',
    );
  }

  static String encode(List<Cliente> clientes) => json.encode(
        clientes.map<Map<String, dynamic>>((c) => c.toMap()).toList(),
      );

  static List<Cliente> decode(String clientesJson) =>
      (json.decode(clientesJson) as List<dynamic>)
          .map<Cliente>((item) => Cliente.fromMap(item))
          .toList();
}
