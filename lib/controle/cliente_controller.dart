import '../modelo/classes/cliente.dart';
import '../modelo/local_storage_service.dart';
import 'pedido_controller.dart';

/// CRUD de Cliente e controle de sessão (login/logout).
class ClienteController {
  // Create

  /// Retorna null se o e-mail já estiver cadastrado.
  static Future<Cliente?> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
    required String endereco,
  }) async {
    List<Cliente> clientes = await LocalStorageService.carregarClientes();

    final bool emailJaExiste =
        clientes.any((c) => c.email.toLowerCase() == email.toLowerCase());
    if (emailJaExiste) return null;

    final int novoId = clientes.isEmpty
        ? 1
        : clientes.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;

    final novoCliente = Cliente(
      id: novoId,
      nome: nome,
      email: email,
      senha: senha,
      telefone: telefone,
      endereco: endereco,
    );

    clientes.add(novoCliente);
    await LocalStorageService.salvarClientes(clientes);
    return novoCliente;
  }

  // Read / Login

  static Future<Cliente?> login(String email, String senha) async {
    List<Cliente> clientes = await LocalStorageService.carregarClientes();

    for (final cliente in clientes) {
      if (cliente.email.toLowerCase() == email.toLowerCase() &&
          cliente.senha == senha) {
        await LocalStorageService.salvarSessao(cliente.id);
        return cliente;
      }
    }
    return null;
  }

  static Future<Cliente?> clienteLogado() async {
    final int? id = await LocalStorageService.carregarSessao();
    if (id == null) return null;

    List<Cliente> clientes = await LocalStorageService.carregarClientes();
    for (final cliente in clientes) {
      if (cliente.id == id) return cliente;
    }
    return null;
  }

  static Future<void> logout() async {
    await LocalStorageService.limparSessao();
  }

  // Update

  static Future<void> atualizar(Cliente clienteAtualizado) async {
    List<Cliente> clientes = await LocalStorageService.carregarClientes();

    final int index = clientes.indexWhere((c) => c.id == clienteAtualizado.id);
    if (index != -1) {
      clientes[index] = clienteAtualizado;
      await LocalStorageService.salvarClientes(clientes);
    }
  }

  // Delete

  /// Exclui a conta, os pedidos do cliente e encerra a sessão.
  static Future<void> excluirConta(int clienteId) async {
    List<Cliente> clientes = await LocalStorageService.carregarClientes();
    clientes.removeWhere((c) => c.id == clienteId);
    await LocalStorageService.salvarClientes(clientes);

    await PedidoController.excluirPedidosDoCliente(clienteId);
    await LocalStorageService.limparSessao();
  }
}
