import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:metrecicla_app/utils/api_endpoints.dart';
import 'package:metrecicla_app/screens/home.dart';
import 'package:metrecicla_app/services/auth_service.dart'; // Importar AuthService

class LoginController extends GetxController {
  final AuthService authService = AuthService(); // Instanciar AuthService
  TextEditingController txtCedulaController = TextEditingController();
  TextEditingController txtPasswordController = TextEditingController();

  Future<void> loginUsuario() async {
    var headers = {'Content-Type': 'application/json'};
    try {
      var url =
          Uri.parse(ApiEndPoints.baseUrl + ApiEndPoints.endpoints.loginService);
      Map body = {
        'cedula': txtCedulaController.text.trim(),
        'contraseña': txtPasswordController.text,
        'operacion': 'LOGIN'
      };

      http.Response response =
          await http.post(url, body: jsonEncode(body), headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['jwt'] != null) {
          final String jwt = json['jwt'];

          // Guardar el JWT usando AuthService
          await authService.saveJwt(jwt);

          txtCedulaController.clear();
          txtPasswordController.clear();

          Get.off(() => const HomeScreen());
        } else {
          throw 'Usuario o Contraseña incorrectos';
        }
      } else {
        throw 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (error) {
      Get.back();
      showDialog(
        context: Get.context!,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Error'),
            contentPadding: const EdgeInsets.all(20),
            children: [Text(error.toString())],
          );
        },
      );
    }
  }

  Future<void> signOut() async {
    await Get.find<AuthService>().deleteJwt(); // Elimina el JWT almacenado
  }
}
