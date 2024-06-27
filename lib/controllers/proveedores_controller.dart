import 'dart:convert';

import 'package:metrecicla_app/controllers/api_interceptor.dart';
import 'package:metrecicla_app/services/auth_service.dart';
import 'package:metrecicla_app/utils/api_endpoints.dart';

class ProveedoresController {
  final AuthService authService = AuthService(); // Instanciar AuthService
  final ApiInterceptor _apiInterceptor;

  ProveedoresController(this._apiInterceptor);

  Future<List<Map<String, dynamic>>> fetchProveedores() async {
    try {
      final jwt = await authService.getJwt(); // Obtener JWT usando AuthService

      final Uri url = Uri.parse(
          ApiEndPoints.baseUrl + ApiEndPoints.endpoints.getProveedoresService);
      final response = await _apiInterceptor.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<Map<String, dynamic>> proveedores =
            List<Map<String, dynamic>>.from(jsonData['data']['resultado']);
        return proveedores;
      } else {
        throw Exception('Failed to load proveedores');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> updateProveedor(
      String jwt, Map<String, dynamic> proveedor) async {
    final Uri url = Uri.parse(
        '${ApiEndPoints.baseUrl + ApiEndPoints.endpoints.getProveedoresService}?id=${proveedor['id']}');
    final response = await _apiInterceptor.put(
      url,
      headers: {
        'Cookie': 'jwt=$jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_proveedor': proveedor['id_proveedor'],
        'nombre': proveedor['nombre'],
        'direccion': proveedor['direccion'],
        'telefono': proveedor['telefono'],
        'activo': 1
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update proveedor');
    }
  }

  Future<void> addProveedor(
      String jwt, Map<String, dynamic> newProveedor) async {
    final url = Uri.parse(
        ApiEndPoints.baseUrl + ApiEndPoints.endpoints.getProveedoresService);
    final response = await _apiInterceptor.post(
      url,
      headers: {
        'Cookie': 'jwt=$jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(newProveedor),
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Error al añadir proveedor: ${response.statusCode}');
    }
  }

  Future<void> deleteProveedor(String jwt, int idProveedor) async {
    try {
      final Uri url = Uri.parse(
          '${ApiEndPoints.baseUrl + ApiEndPoints.endpoints.getProveedoresService}');

      final response = await _apiInterceptor.delete(
        url,
        headers: {
          'Cookie': 'jwt=$jwt',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_proveedor': idProveedor,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete proveedor');
      }
    } catch (e) {
      throw Exception('Error deleting proveedor: $e');
    }
  }
}
