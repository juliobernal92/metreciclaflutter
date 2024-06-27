import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metrecicla_app/utils/api_endpoints.dart';
import 'package:metrecicla_app/screens/home.dart';

class LoginController extends GetxController {
  TextEditingController txtCedulaController = TextEditingController();
  TextEditingController txtPasswordController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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
          final SharedPreferences prefs = await _prefs;
          await prefs.setString('jwt', jwt);

          // Obtener y almacenar nombres si está presente
          if (json['nombres'] != null) {
            String nombres = json['nombres'];
            await prefs.setString('nombres', nombres);
          } else {
            throw 'No se recibió el nombre';
          }

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
          });
    }
  }

  Future<Map<String, String>> getHeaders() async {
    final SharedPreferences prefs = await _prefs;
    final String? jwt = prefs.getString('jwt');
    if (jwt != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt'
      };
    } else {
      return {
        'Content-Type': 'application/json',
      };
    }
  }

  Future<void> signOut() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove('jwt');
  }
}
