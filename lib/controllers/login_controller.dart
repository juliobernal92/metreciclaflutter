import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:metrecicla_app/utils/api_endpoints.dart';
import 'package:metrecicla_app/screens/home.dart';
import 'package:metrecicla_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importar AuthService

class LoginController extends GetxController {
  final AuthService authService = Get.find();

  //final AuthService authService = AuthService(); // Instanciar AuthService
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

          // Guardar el JWT usando AuthService
          await authService.saveJwt(jwt);
          final String nombres = json['nombres'];
          final SharedPreferences prefs = await _prefs;
          await prefs.setString('nombres', nombres);
          // Guarda el id_empleado correctamente
          final int idEmpleado = json['id'];
          await prefs.setInt('id_empleado', idEmpleado);
          print("ID AL INICIAR SESION: $idEmpleado");

          txtCedulaController.clear();
          txtPasswordController.clear();

          Get.off(() => const HomeScreen());
        } else {
          throw 'Usuario o Contraseña incorrectos';
        }
      } else {
        throw 'Usuario o Contraseña incorrectos';
        //throw 'Error: ${response.statusCode} - ${response.body}';
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
