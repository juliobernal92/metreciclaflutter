import 'package:flutter/material.dart';
import 'package:metrecicla_app/controllers/api_interceptor.dart';
import 'package:metrecicla_app/controllers/proveedores_controller.dart';
import 'package:metrecicla_app/screens/add_proveedor_dialog.dart';
import 'package:metrecicla_app/screens/edit_proveedor_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  late ProveedoresController _proveedoresController;

  List<Map<String, dynamic>> _proveedores = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _proveedoresController = ProveedoresController(ApiInterceptor(context));
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String jwt = await _getStoredJwtToken();
      List<Map<String, dynamic>> chatarras =
          await _proveedoresController.fetchProveedores();

      setState(() {
        _proveedores = chatarras;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getStoredJwtToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Proveedores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _handleAddProveedor,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 20.0, // Espacio entre las columnas
                  columns: const [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Dirección')),
                    DataColumn(label: Text('Teléfono')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows: _proveedores
                      .map(
                        (proveedor) => DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width:
                                    120, // Ajusta el ancho máximo para el nombre
                                child: Text(proveedor['nombre'] ?? ''),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width:
                                    120, // Ajusta el ancho máximo para la dirección
                                child: Text(proveedor['direccion'] ?? ''),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width:
                                    100, // Ajusta el ancho máximo para el teléfono
                                child: Text(proveedor['telefono'] ?? ''),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _handleEditProveedor(proveedor),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _handleDeleteProveedor(proveedor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
    );
  }

  Future<void> _handleEditProveedor(Map<String, dynamic> proveedor) async {
    final updatedProveedor = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditProveedorDialog(proveedor: proveedor),
    );

    if (updatedProveedor != null) {
      try {
        final String jwt = await _getStoredJwtToken();
        await _proveedoresController.updateProveedor(jwt, updatedProveedor);
        _fetchData();
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _handleAddProveedor() async {
    final newProveedor = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddProveedorDialog(),
    );

    if (newProveedor != null) {
      try {
        final String jwt = await _getStoredJwtToken();
        await _proveedoresController.addProveedor(jwt, newProveedor);
        _fetchData();
      } catch (e) {
        print('Error adding proveedor: $e');
      }
    }
  }

  Future<void> _handleDeleteProveedor(Map<String, dynamic> proveedor) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de eliminar a este proveedor?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        final String jwt = await _getStoredJwtToken();
        final int idProveedor = proveedor['id_proveedor'];

        await _proveedoresController.deleteProveedor(jwt, idProveedor);
        _fetchData();
      } catch (e) {
        print('Error deleting proveedor: $e');
      }
    }
  }
}
