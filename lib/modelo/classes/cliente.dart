import 'dart:convert';

/// Representa o cliente logado. A senha não fica no app:
/// quem confere a senha é o servidor.
class Cliente {
  final int id;
  final String nome;
  final String email;
  final String telefone;
  final String endereco;

  Cliente({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.endereco,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'endereco': endereco,
    };
  }

  /// Serve tanto para a resposta da API quanto para a cópia salva no aparelho
  /// (os dois usam os mesmos nomes de campo).
  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] ?? 0,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
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
