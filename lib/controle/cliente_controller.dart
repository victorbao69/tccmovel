import '../modelo/api_service.dart';
import '../modelo/classes/cliente.dart';
import '../modelo/local_storage_service.dart';

/// Cadastro, login e conta do cliente. Tudo passa pela API do site;
/// os métodos lançam [ApiException] com a mensagem pronta quando algo dá errado.
class ClienteController {
  // Create

  static Future<Cliente> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
    required String endereco,
  }) async {
    final resposta = await ApiService.post('/register', corpo: {
      'name': nome,
      'email': email,
      'password': senha,
      'telefone': telefone,
      'endereco': endereco,
    });
    return _guardarSessao(resposta);
  }

  // Read / Login

  static Future<Cliente> login(String email, String senha) async {
    final resposta = await ApiService.post('/login', corpo: {
      'email': email,
      'password': senha,
    });
    return _guardarSessao(resposta);
  }

  /// Devolve o cliente logado, ou null se não houver login válido.
  /// Sem internet, usa a cópia dos dados salva no aparelho.
  static Future<Cliente?> clienteLogado() async {
    final String? token = await LocalStorageService.carregarToken();
    if (token == null) return null;

    try {
      final resposta = await ApiService.get('/me', autenticado: true);
      final cliente = Cliente.fromMap(resposta);
      await LocalStorageService.salvarCliente(cliente);
      return cliente;
    } on ApiException catch (erro) {
      if (erro.statusCode == 401) {
        // Token inválido ou expirado: precisa entrar de novo
        await LocalStorageService.limparSessao();
        return null;
      }
      return await LocalStorageService.carregarCliente();
    }
  }

  static Future<void> logout() async {
    try {
      await ApiService.post('/logout', autenticado: true);
    } on ApiException {
      // Mesmo que o servidor não responda, o logout local acontece
    }
    await LocalStorageService.limparSessao();
  }

  // Update

  /// [novaSenha] é opcional: se vier vazia, a senha continua a mesma.
  static Future<Cliente> atualizar(Cliente cliente, {String novaSenha = ''}) async {
    final Map<String, dynamic> corpo = {
      'name': cliente.nome,
      'email': cliente.email,
      'telefone': cliente.telefone,
      'endereco': cliente.endereco,
    };
    if (novaSenha.isNotEmpty) {
      corpo['password'] = novaSenha;
    }

    final resposta = await ApiService.put('/me', corpo: corpo, autenticado: true);
    final atualizado = Cliente.fromMap(resposta);
    await LocalStorageService.salvarCliente(atualizado);
    return atualizado;
  }

  // Delete

  /// Exclui a conta (e os pedidos dela) no servidor e encerra a sessão.
  static Future<void> excluirConta() async {
    await ApiService.delete('/me', autenticado: true);
    await LocalStorageService.limparSessao();
  }

  /// Salva o token e os dados do cliente que a API devolveu no login/cadastro.
  static Future<Cliente> _guardarSessao(dynamic resposta) async {
    await LocalStorageService.salvarToken(resposta['token']);
    final cliente = Cliente.fromMap(resposta['cliente']);
    await LocalStorageService.salvarCliente(cliente);
    return cliente;
  }
}
