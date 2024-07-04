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
  late TextEditingController idChatarraController;
  late TextEditingController idTicketController;
  late TextEditingController fechaController;
  late TextEditingController idEmpleadoController;
  late TextEditingController cantidadController;
  late TextEditingController precioController;
  late TextEditingController nombreController;
  late TextEditingController direccionController;
  late TextEditingController telefonoController;

  ComprasController(this.apiInterceptor);
  var chatarras = <Map<String, dynamic>>[].obs;
  @override
  void onInit() {
    super.onInit();
    fetchChatarras();
  }

  Future<void> addProveedor(
      String nombre, String direccion, String telefono) async {
    if (nombre.isEmpty || direccion.isEmpty || telefono.isEmpty) {
      Get.snackbar(
        'Error',
        'Todos los campos son requeridos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(
          Icons.error,
          color: Colors.white,
        ),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

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

        final response = await apiInterceptor.post(
          url,
          headers: {
            'Cookie': 'jwt=$jwt',
            'Content-Type': 'application/json',
          },
          body: body,
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final idProveedor = jsonResponse['data']['id_proveedor'];

          final SharedPreferences prefs = await _prefs;
          await prefs.setString('id_proveedor', idProveedor);

          idProveedorController.text = idProveedor;

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

  Future<void> addporIdProveedor(String idProveedor) async {
    if (idProveedor.isEmpty) {
      Get.snackbar(
        'Error',
        'ID del proveedor es requerido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(
          Icons.error,
          color: Colors.white,
        ),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      final jwt = await authService.getJwt();
      final url = Uri.parse(
          '${ApiEndPoints.baseUrl + ApiEndPoints.endpoints.getProveedoresService}?id=${idProveedor}');
      final response = await apiInterceptor.get(
        url,
        headers: {
          'Cookie': 'jwt=$jwt',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data']['resultado'].isNotEmpty) {
          Get.snackbar('Éxito', 'Proveedor cargado correctamente');
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
          Get.snackbar(
              'Error', 'No se encontró el proveedor con el ID: $idProveedor');
          // Limpiar campos en SharedPreferences o tomar otra acción según tu lógica
          idProveedorController.clear();
          nombreController.clear();
          direccionController.clear();
          telefonoController.clear();

          final SharedPreferences prefs = await _prefs;
          await prefs.remove('nombre');
          await prefs.remove('direccion');
          await prefs.remove('telefono');
        }
      } else {
        Get.snackbar(
            'Error', 'Error al cargar proveedor: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al cargar proveedor');
    }
  }

  Future<void> fetchChatarras() async {
    try {
      final jwt = await authService.getJwt();
      final url = Uri.parse(
          ApiEndPoints.baseUrl + ApiEndPoints.endpoints.getchatarrasService);

      final response = await apiInterceptor.get(
        url,
        headers: {
          'Cookie': 'jwt=$jwt',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data']['resultado'].isNotEmpty) {
          chatarras.value =
              List<Map<String, dynamic>>.from(jsonResponse['data']['resultado'])
                  .cast<Map<String, dynamic>>();
        } else {
          Get.snackbar('Error', 'No se encontraron chatarras');
        }
      } else {
        Get.snackbar(
            'Error', 'Error al cargar chatarras: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    }
  }

  Future<String?> addTicketCompra(
      String fecha, String idProveedor, String idEmpleado) async {
    // Validar campos requeridos
    if (fecha.isEmpty || idProveedor.isEmpty || idEmpleado.isEmpty) {
      Get.snackbar(
        'Error',
        'Todos los campos son requeridos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(
          Icons.error,
          color: Colors.white,
        ),
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }

    try {
      final jwt = await authService.getJwt();
      final url = Uri.parse(
          ApiEndPoints.baseUrl + ApiEndPoints.endpoints.addTicketCompraService);
      final body = jsonEncode({
        'fecha': fecha,
        'id_proveedor': idProveedor,
        'id_empleado': idEmpleado
      });

      final response = await apiInterceptor.post(
        url,
        headers: {
          'Cookie': 'jwt=$jwt',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final idTicket = jsonResponse['data']['id_ticketcompra'];

        // Actualizar ID del ticket en SharedPreferences
        final SharedPreferences prefs = await _prefs;
        await prefs.setString('id_ticketcompra', idTicket);

        // Actualizar el controlador de texto
        idTicketController.text = idTicket;

        return idTicket; // Devolver el ID del ticket creado
      } else {
        Get.snackbar('Error', 'Error al añadir ticket: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
      return null;
    }
  }

  Future<void> addDetalleCompraOK(String idChatarra, String idTicketCompra,
      String cantidadStr, String precioStr) async {
    try {
      // Validar que los campos no estén vacíos
      if (idChatarra.isEmpty ||
          idTicketCompra.isEmpty ||
          cantidadStr.isEmpty ||
          precioStr.isEmpty) {
        Get.snackbar('Error', 'Todos los campos son requeridos');
        return;
      }

      // Convertir las cadenas de texto a números y validar que sean correctas
      double? cantidad = double.tryParse(cantidadStr);
      int? precio = int.tryParse(precioStr);

      if (cantidad == null || precio == null) {
        Get.snackbar(
          'Error',
          'Todos los campos son requeridos',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Calcular el subtotal
      var subtotal = cantidad * precio;

      final jwt = await authService.getJwt();
      final url = Uri.parse(ApiEndPoints.baseUrl +
          ApiEndPoints.endpoints.addDetalleCompraService);
      final body = jsonEncode({
        'id_ticketcompra': idTicketCompra,
        'id_chatarra': idChatarra,
        'cantidad': cantidad,
        'preciopagado': precio,
        'subtotal': subtotal,
      });
      final response = await apiInterceptor.post(
        url,
        headers: {
          'Cookie': 'jwt=$jwt',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        idChatarraController.clear();
        precioController.clear();
        cantidadController.clear();
        Get.snackbar('Éxito', 'Chatarra añadida correctamente');
        return jsonResponse['success'];
      } else {
        Get.snackbar('Error', 'Error al añadir');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al añadir');
    }
  }

  Future<List<Map<String, dynamic>>> fetchDetallesCompraPorTicket(
      String idTicket) async {
    try {
      final jwt = await authService.getJwt();
      final url = Uri.parse(
          '${ApiEndPoints.baseUrl + ApiEndPoints.endpoints.addDetalleCompraService}?id=${idTicket}');

      final response = await apiInterceptor.get(
        url,
        headers: {
          'Cookie': 'jwt=$jwt',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['codigo'] == 200) {
          return List<Map<String, dynamic>>.from(
              jsonResponse['data']['resultado']);
        } else {
          throw Exception('Error al obtener detalles de compra');
        }
      } else {
        throw Exception(
            'Error al obtener detalles de compra: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> updateDetalle(String jwt, Map<String, dynamic> detalle) async {
    final Uri url = Uri.parse(
        '${ApiEndPoints.baseUrl + ApiEndPoints.endpoints.addDetalleCompraService}?id=${detalle['id']}');
    final response = await apiInterceptor.put(
      url,
      headers: {
        'Cookie': 'jwt=$jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_detallecompra': detalle['id_detallecompra'],
        'nuevaCantidad': detalle['cantidad'],
        'nuevoPrecio': detalle['nuevoPrecio'],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update detalle compra');
    }
  }

  //Eliminar detalle
  Future<void> deleteDetalle(String jwt, int idDetalle) async {
    try {
      final Uri url = Uri.parse(ApiEndPoints.baseUrl +
          ApiEndPoints.endpoints.addDetalleCompraService);

      final response = await apiInterceptor.delete(
        url,
        headers: {
          'Cookie': 'jwt=$jwt',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_detallecompra': idDetalle,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete detalle');
      }
    } catch (e) {
      throw Exception('Error deleting detalle: $e');
    }
  }
}
