import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // TODO: Substituir pela URL real da sua API
  static const String baseUrl = 'https://sua-api.com/api';
  
  Future<double?> analisarPesoSuino(File imagemFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analisar-peso'),
      );

      // Adiciona a imagem ao request
      request.files.add(
        await http.MultipartFile.fromPath(
          'imagem',
          imagemFile.path,
        ),
      );

      // Adiciona headers se necessário
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        // 'Authorization': 'Bearer YOUR_TOKEN', // Se precisar de autenticação
      });

      // Envia o request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Ajuste conforme o formato de resposta da sua API
        // Exemplo: { "peso": 85.5, "confianca": 0.95 }
        return data['peso']?.toDouble();
      } else {
        print('Erro na API: ${response.statusCode}');
        print('Resposta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao chamar API: $e');
      return null;
    }
  }

  // Método para testar a conexão com a API
  Future<bool> testarConexao() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao testar conexão: $e');
      return false;
    }
  }

  // Método simulado para desenvolvimento (remover em produção)
  Future<double> simularAnalise() async {
    // Simula um delay da API
    await Future.delayed(const Duration(seconds: 2));
    
    // Retorna um peso aleatório entre 60 e 120 kg
    return 60 + (60 * (DateTime.now().millisecond / 1000));
  }
}
