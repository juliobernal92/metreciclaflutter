import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metrecicla_app/controllers/api_interceptor.dart';
import 'package:metrecicla_app/services/auth_service.dart';
import 'package:metrecicla_app/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComprasController extends GetxController {
  final AuthService authService = AuthService();
  final ApiInterceptor apiInterceptor;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late TextEditingController idProveedorController;

  ComprasController(this.apiInterceptor);

  Future<void> addProveedor(
      String nombre, String direccion, String telefono) async {
    if (idProveedorController.text.isEmpty) {
      try {
        final jwt = await authService.getJwt();
        final url = Uri.parse(ApiEndPoints.baseUrl +
            ApiEndPoints.endpoints.addProveedoresService);

        final body = jsonEncode({
          'nombre': nombre,
          'direccion': direccion,
          'telefono': telefono,
          'activo': 1,
        });

        print('Request body: $body');

        final response = await apiInterceptor.post(
          url,
          headers: {
            'Cookie': 'jwt=$jwt',
            'Content-Type': 'application/json',
          },
          body: body,
        );

        print('Response: ${response.statusCode} ${response.body}');

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final idProveedor = jsonResponse['data']['id_proveedor'];

          // Actualizar ID del proveedor en SharedPreferences
          final SharedPreferences prefs = await _prefs;
          await prefs.setString('id_proveedor', idProveedor);

          // Actualizar el controlador de texto
          idProveedorController.text = idProveedor;

          //print("Id que se recupera de json response: " + idProveedor);
          //print("respuesta del servidor: " + jsonResponse);
          Get.snackbar('Éxito', 'Proveedor añadido correctamente');
        } else {
          Get.snackbar(
              'Error', 'Error al añadir proveedor: ${response.statusCode}');
        }
      } catch (e) {
        Get.snackbar('Error', 'Error: $e');
      }
    } else {
      Get.snackbar(
        'Error',
        'Ya añadiste un proveedor',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(
          Icons.error,
          color: Colors.white,
        ),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> addporIdProveedor(String idproveedor) async {
    try {
      final jwt = await authService.getJwt();
      final url = Uri.parse(
          '${ApiEndPoints.baseUrl + ApiEndPoints.endpoints.getProveedoresService}?id=${idproveedor}');
      final response = await apiInterceptor.get(
        url,
        headers: {
          'Cookie': 'jwt=$jwt',
          'Content-Type': 'application/json',
        },
      );
      print('URL enviada: $url');
      print('StatusCode: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
      if (response.statusCode == 200) {
        Get.snackbar('Éxito', 'Proveedor cargado correctamente');
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data']['resultado'].isNotEmpty) {
          final proveedor = jsonResponse['data']['resultado'][0];
          final nombre = proveedor['nombre'];
          final direccion = proveedor['direccion'];
          final telefono = proveedor['telefono'];

          // Actualizar campos en SharedPreferences
          final SharedPreferences prefs = await _prefs;
          await prefs.setString('nombre', nombre);
          await prefs.setString('direccion', direccion);
          await prefs.setString('telefono', telefono);
        } else {
          Get.snackbar('Error', 'No se encontró el proveedor');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al cargar proveedor');
    }
  }

  void addDetalleCompra(String idChatarra, String precio, String cantidad) {
    //no implementar todavia
  }

  void removeDetalleCompra(int index) {
    //no implementar todavia
  }
}
