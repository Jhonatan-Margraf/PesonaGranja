import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // <--- IMPORTANTE
import 'package:image_picker/image_picker.dart';

class ApiService {
  // Verifique se o URL do Ngrok não mudou (eles mudam a cada restart da versão free)
  final String baseUrl = "https://9547-177-39-139-130.ngrok-free.app";

  Future<double?> analisarPesoSuino(XFile imagemXFile) async {
    try {
      final url = Uri.parse('$baseUrl/predict-json');
      var request = http.MultipartRequest('POST', url);

      // --- CABEÇALHOS PARA EVITAR BLOQUEIO DO NGROK/BROWSER ---
      request.headers.addAll({
        "ngrok-skip-browser-warning": "true",
        "Access-Control-Allow-Origin": "*",
      });

      if (kIsWeb) {
        // --- WEB: LER BYTES E DEFINIR CONTENT-TYPE ---
        final bytes = await imagemXFile.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'upload.jpg',
            contentType:
                MediaType('image', 'jpeg'), // <--- CORREÇÃO DO ERRO 400
          ),
        );
      } else {
        // --- MOBILE: LER DO DISCO ---
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            imagemXFile.path,
            contentType: MediaType('image', 'jpeg'), // Também ajuda no Mobile
          ),
        );
      }

      print("Enviando requisição para $url..."); // Log para debug

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Status Code: ${response.statusCode}");
      print("Corpo da Resposta: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('peso_kg')) {
          return (data['peso_kg'] as num).toDouble();
        } else {
          // Se a sua API retorna outro nome, ajuste aqui
          print("Campo peso_kg não encontrado. Dados: $data");
          return null;
        }
      } else {
        // Mostra o erro que vem do servidor (ex: "Arquivo inválido")
        throw Exception(
            "Erro do servidor (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Erro ApiService: $e");
      rethrow; // Passa o erro para a tela tratar
    }
  }
}
