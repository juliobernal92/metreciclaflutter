import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:metrecicla_app/utils/api_endpoints.dart';

class ChatarraController {
  Future<List<Map<String, dynamic>>> fetchChatarras(String jwt) async {
    try {
      final Uri url = Uri.parse(
          ApiEndPoints.baseUrl + ApiEndPoints.endpoints.getchatarrasService);
      final response = await http.get(
        url,
        headers: {
          'Cookie': 'jwt=$jwt',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<Map<String, dynamic>> chatarras =
            List<Map<String, dynamic>>.from(jsonData['data']['resultado']);
        return chatarras;
      } else {
        throw Exception('Failed to load chatarras');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> updateChatarra(String jwt, Map<String, dynamic> chatarra) async {
    final Uri url = Uri.parse(
        '${ApiEndPoints.baseUrl + ApiEndPoints.endpoints.editChatarrasService}?id=${chatarra['id']}');
    final response = await http.put(
      url,
      headers: {
        'Cookie': 'jwt=$jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_chatarra': chatarra['id_chatarra'],
        'nombre': chatarra['nombre'],
        'precio': chatarra['precio'],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update chatarra');
    }
  }

  Future<void> addChatarra(String jwt, Map<String, dynamic> newChatarra) async {
    final url = Uri.parse(
        ApiEndPoints.baseUrl + ApiEndPoints.endpoints.addChatarrasService);
    final response = await http.post(
      url,
      headers: {
        'Cookie': 'jwt=$jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(newChatarra),
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Error al añadir chatarra: ${response.statusCode}');
    }
  }

  Future<void> deleteChatarra(String jwt, int idChatarra) async {
    try {
      final Uri url = Uri.parse(
          '${ApiEndPoints.baseUrl + ApiEndPoints.endpoints.deleteChatarrasService}');

      final response = await http.delete(
        url,
        headers: {
          'Cookie': 'jwt=$jwt',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_chatarra': idChatarra,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete chatarra');
      }
    } catch (e) {
      throw Exception('Error deleting chatarra: $e');
    }
  }
}
