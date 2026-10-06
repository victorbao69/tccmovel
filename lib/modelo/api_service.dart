import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config_api.dart';
import 'local_storage_service.dart';

/// Erro das chamadas à API. A [mensagem] já vem pronta para mostrar ao usuário.
class ApiException implements Exception {
  final String mensagem;
  final int? statusCode;

  /// true quando não foi possível nem falar com o servidor (sem internet).
  final bool semConexao;

  ApiException(this.mensagem, {this.statusCode, this.semConexao = false});

  @override
  String toString() => mensagem;
}

/// Resultado de uma listagem. [offline] é true quando a lista veio do
/// que está salvo no aparelho porque não deu para falar com o servidor.
class ResultadoLista<T> {
  final List<T> lista;
  final bool offline;

  ResultadoLista(this.lista, {this.offline = false});
}

/// Faz as chamadas HTTP para a API do site e devolve o JSON já decodificado.
class ApiService {
  static Future<dynamic> get(String caminho, {bool autenticado = false}) {
    return _enviar('GET', caminho, autenticado: autenticado);
  }

  static Future<dynamic> post(String caminho,
      {Map<String, dynamic>? corpo, bool autenticado = false}) {
    return _enviar('POST', caminho, corpo: corpo, autenticado: autenticado);
  }

  static Future<dynamic> put(String caminho,
      {Map<String, dynamic>? corpo, bool autenticado = false}) {
    return _enviar('PUT', caminho, corpo: corpo, autenticado: autenticado);
  }

  static Future<dynamic> delete(String caminho, {bool autenticado = false}) {
    return _enviar('DELETE', caminho, autenticado: autenticado);
  }

  static Future<dynamic> _enviar(
    String metodo,
    String caminho, {
    Map<String, dynamic>? corpo,
    bool autenticado = false,
  }) async {
    final Uri uri = Uri.parse('$apiBaseUrl$caminho');

    // "Accept: application/json" faz o Laravel responder erros em JSON.
    // "Referer": o servidor (DOM Cloud) bloqueia pedidos que não dizem de
    // qual site vieram; sem isso o nginx responde 405 antes de chegar no Laravel.
    final Map<String, String> cabecalhos = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Referer': 'https://tcc-web.sao.dom.my.id/',
    };

    if (autenticado) {
      final String? token = await LocalStorageService.carregarToken();
      if (token == null) {
        throw ApiException('Faça login novamente.', statusCode: 401);
      }
      cabecalhos['Authorization'] = 'Bearer $token';
    }

    final String? corpoJson = corpo == null ? null : json.encode(corpo);
    http.Response resposta;

    try {
      switch (metodo) {
        case 'POST':
          resposta = await http.post(uri, headers: cabecalhos, body: corpoJson);
          break;
        case 'PUT':
          resposta = await http.put(uri, headers: cabecalhos, body: corpoJson);
          break;
        case 'DELETE':
          resposta = await http.delete(uri, headers: cabecalhos);
          break;
        default:
          resposta = await http.get(uri, headers: cabecalhos);
      }

    } on TimeoutException {
      throw ApiException('O servidor demorou demais para responder.', semConexao: true);
    } catch (_) {
      throw ApiException('Sem conexão com o servidor.', semConexao: true);
    }

    dynamic dados;
    try {
      dados = resposta.body.isEmpty ? null : json.decode(resposta.body);
    } catch (_) {
      dados = null;
    }

    if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
      return dados;
    }

    throw ApiException(
      _extrairMensagem(dados, resposta.statusCode),
      statusCode: resposta.statusCode,
    );
  }

  /// Procura a mensagem de erro na resposta do Laravel.
  static String _extrairMensagem(dynamic dados, int statusCode) {
    if (dados is Map) {
      // Nossos erros: {"mensagem": "..."}
      if (dados['mensagem'] is String) return dados['mensagem'];

      // Erros de validação: {"errors": {"campo": ["texto", ...]}}
      if (dados['errors'] is Map) {
        for (final erros in (dados['errors'] as Map).values) {
          if (erros is List && erros.isNotEmpty) return erros.first.toString();
        }
      }

      if (dados['message'] is String) return dados['message'];
    }
    return 'Erro no servidor (código $statusCode).';
  }
}