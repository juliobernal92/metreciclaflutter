import 'dart:convert';
import 'package:metrecicla_app/controllers/api_interceptor.dart';
import 'package:metrecicla_app/services/auth_service.dart';
import 'package:metrecicla_app/utils/api_endpoints.dart';

class ChatarraController {
  final AuthService authService = AuthService();
  final ApiInterceptor _apiInterceptor;

  ChatarraController(this._apiInterceptor);

  Future<List<Map<String, dynamic>>> fetchChatarras() async {
    try {
      final jwt = await authService.getJwt(); // Obtener JWT usando AuthService

      final Uri url = Uri.parse(
          ApiEndPoints.baseUrl + ApiEndPoints.endpoints.getchatarrasService);
      final response = await _apiInterceptor.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwt',
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
    final response = await _apiInterceptor.put(
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
    final response = await _apiInterceptor.post(
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

      final response = await _apiInterceptor.delete(
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
