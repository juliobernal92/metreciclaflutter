import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importa http correctamente
import 'package:shared_preferences/shared_preferences.dart';

class ApiInterceptor extends http.BaseClient {
  final http.Client _client = http.Client();
  final BuildContext context;

  ApiInterceptor(this.context);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt = prefs.getString('jwt') ?? '';

    // Set JWT token in the request headers
    request.headers['Cookie'] = 'jwt=$jwt';

    final response = await _client.send(request);

    // Check for JWT expiration
    if (response.statusCode == 401) {
      // JWT expired, navigate to login screen
      _redirectToLogin();
    }

    return http.StreamedResponse(
      response.stream,
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  void _redirectToLogin() {
    // Navigate to login screen
    Navigator.of(context).pushReplacementNamed(
        '/login'); // Reemplaza con la ruta correcta de tu pantalla de login
  }
}
