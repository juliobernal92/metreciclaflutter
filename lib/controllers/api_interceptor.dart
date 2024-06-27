import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:metrecicla_app/controllers/login_controller.dart';
import 'package:metrecicla_app/screens/login_screen.dart';
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

    return response;
  }

  void _redirectToLogin() {
    // Show a dialog indicating that the session has expired
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sesión expirada'),
          content: const Text(
              'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Get.find<LoginController>().signOut();
                Get.offAll(() => const LoginScreen());
              },
            ),
          ],
        );
      },
    );
  }
}
