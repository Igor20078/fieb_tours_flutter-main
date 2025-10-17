import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/aluno.dart';
import '../models/passeio.dart';
import '../models/avaliacao.dart';

class ApiService {
  //static const String baseUrl = 'http://10.0.2.2:8080/api';
   static const String baseUrl = 'http://localhost:8080/api';

  // ========================
  // LOGIN
  // ========================
  static Future<Aluno> login(String rm, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/alunos/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rm': rm, 'senhaBase64': senha}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Aluno.fromJson(jsonDecode(response.body));
      } else {
        final msg = _getErrorMessage(response);
        throw Exception('Falha no login: $msg');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  // ========================
  // REGISTRO DE ALUNO
  // ========================
  static Future<Aluno> registrarAluno(Aluno aluno) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/alunos/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(aluno.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Aluno.fromJson(jsonDecode(response.body));
      } else {
        final msg = _getErrorMessage(response);
        throw Exception('Erro ao registrar aluno: $msg');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  // ========================
  // RESERVAS
  // ========================
  static Future<List<dynamic>> getReservas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservas'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao buscar reservas: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  static Future<List<dynamic>> getReservasByUsuario(String rm) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservas/usuario/$rm'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao buscar reservas do usuário: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  // ========================
  // PASSEIOS
  // ========================
  static Future<List<Passeio>> getPasseios() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/passeios'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Passeio.fromJson(e)).toList();
      } else {
        final msg = _getErrorMessage(response);
        throw Exception('Erro ao buscar passeios: $msg');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  static Future<List<Passeio>> getPasseiosUsuario(int alunoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/passeios/usuario/$alunoId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Passeio.fromJson(e)).toList();
      } else {
        final msg = _getErrorMessage(response);
        throw Exception('Erro ao buscar passeios do usuário: $msg');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  // ========================
  // RESERVAS
  // ========================
  static Future<void> reservarPasseio(Passeio passeio, Aluno aluno) async {
    try {
      // Monta o DTO correto conforme o backend espera
      final dto = {
        'passeioId': passeio.id, // id do passeio
        'alunoRm': aluno.rm, // RM do aluno logado
      };

      final response = await http.post(
        Uri.parse('$baseUrl/reservas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dto),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final msg = _getErrorMessage(response);
        throw Exception('Erro ao reservar passeio: $msg');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  // ========================
  // AVALIAÇÕES
  // ========================
  static Future<List<Avaliacao>> getAvaliacoes(int passeioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/avaliacoes/passeio/$passeioId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Avaliacao.fromJson(e)).toList();
      } else {
        final msg = _getErrorMessage(response);
        throw Exception('Erro ao buscar avaliações: $msg');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  static Future<void> enviarAvaliacao(
    int passeioId,
    int alunoId,
    int nota,
    String comentario,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/avaliacoes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'passeioId': passeioId,
          'alunoId': alunoId,
          'nota': nota,
          'comentario': comentario,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final msg = _getErrorMessage(response);
        throw Exception('Erro ao enviar avaliação: $msg');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  // ========================
  // MÉTODOS INTERNOS
  // ========================
  static String _getErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['message'] ?? response.body;
    } catch (_) {
      return response.body.isNotEmpty ? response.body : 'Erro desconhecido';
    }
  }
}
