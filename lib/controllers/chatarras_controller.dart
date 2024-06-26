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
}
