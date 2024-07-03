import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metrecicla_app/controllers/api_interceptor.dart';
import 'package:metrecicla_app/controllers/compras_controller.dart';
import 'package:metrecicla_app/screens/edit_detalle_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});

  @override
  _ComprasScreenState createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  final TextEditingController idProveedorController = TextEditingController();
  final TextEditingController idChatarraController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController idTicketController = TextEditingController();
  final TextEditingController idEmpleadoController = TextEditingController();
  //String? _selectedChatarra;
  Map<String, dynamic>? _selectedChatarra;

  List<Map<String, dynamic>> detallesCompra = [];
  late ComprasController _comprasController;

  @override
  void initState() {
    super.initState();
    // Configura la fecha actual al inicializar el estado
    final DateTime now = DateTime.now();
    fechaController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    _comprasController = ComprasController(ApiInterceptor(context));
    _comprasController.idProveedorController = idProveedorController;
    _comprasController.idChatarraController = idChatarraController;
    _comprasController.idTicketController = idTicketController;
    _comprasController.idEmpleadoController = idEmpleadoController;
    _comprasController.fechaController = fechaController;
    _comprasController.cantidadController = cantidadController;
    _comprasController.precioController = precioController;
    _comprasController.fetchChatarras();
  }

  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idprov = prefs.getString("id_proveedor");
    String? idempleado = prefs.getString("id_empleado");
    if (idempleado != null && idempleado.isNotEmpty) {
      idEmpleadoController.text = idempleado;
    }

    if (idprov != null && idprov.isNotEmpty) {
      idProveedorController.text = idprov;
    }
  }

  void loadsavedataid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombre = prefs.getString("nombre");
    if (nombre != null) {
      setState(() {
        nombreController.text = nombre;
      });
    }

    String? telefono = prefs.getString("telefono");
    if (telefono != null) {
      setState(() {
        telefonoController.text = telefono;
      });
    }

    String? direccion = prefs.getString("direccion");
    if (direccion != null) {
      setState(() {
        direccionController.text = direccion;
      });
    }
  }

  void showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar este detalle de compra?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                setState(() {
                  detallesCompra.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _loadDetallesCompra(String idTicket) {
    _comprasController.fetchDetallesCompraPorTicket(idTicket).then((detalles) {
      setState(() {
        detallesCompra = detalles;
      });
    }).catchError((error) {
      print('Error al cargar detalles de compra: $error');
      // Manejar el error según sea necesario
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        fechaController.text = "${picked.toLocal()}"
            .split(' ')[0]; // Formatea la fecha como "YYYY-MM-DD"
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compras'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Añadir Proveedor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: idProveedorController,
                              decoration: const InputDecoration(
                                  labelText: 'ID Proveedor'),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _comprasController.addporIdProveedor(
                                  idProveedorController.text);
                              loadsavedataid();
                            },
                            icon: const Icon(Icons.search),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: direccionController,
                        decoration:
                            const InputDecoration(labelText: 'Dirección'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: telefonoController,
                        decoration:
                            const InputDecoration(labelText: 'Teléfono'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (idProveedorController.text.isEmpty) {
                            await _comprasController.addProveedor(
                              nombreController.text,
                              direccionController.text,
                              telefonoController.text,
                            );
                            _loadSavedData();
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Guardar Proveedor'),
                      ),
                    ],
                  );
                },
              ),
              const Divider(
                height: 40,
                thickness: 2,
              ),
              const Text(
                'Detalles de Compra',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: fechaController,
                decoration: const InputDecoration(labelText: 'Fecha'),
                onTap: () {
                  _selectDate(context);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: idChatarraController,
                decoration: const InputDecoration(labelText: 'Id Chatarra'),
              ),
              const SizedBox(height: 10),
              Obx(() {
                return DropdownButtonFormField<Map<String, dynamic>>(
                  value: _selectedChatarra,
                  decoration: const InputDecoration(labelText: 'Chatarras'),
                  items: _comprasController.chatarras.map((chatarra) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: chatarra,
                      child: Text(chatarra['nombre']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedChatarra = value;
                      idChatarraController.text =
                          value?['id_chatarra'].toString() ?? '';
                      precioController.text = value?['precio'].toString() ?? '';
                    });
                  },
                );
              }),
              const SizedBox(height: 10),
              TextField(
                controller: precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  int? idemp = prefs.getInt('id_empleado');
                  idEmpleadoController.text = idemp.toString();

                  String? idTicket;
                  if (idTicketController.text.isEmpty) {
                    idTicket = await _comprasController.addTicketCompra(
                      fechaController.text,
                      idProveedorController.text,
                      idEmpleadoController.text,
                    );
                  } else {
                    idTicket = idTicketController.text;
                    _loadDetallesCompra(idTicket);
                  }

                  if (idTicket != null) {
                    await _comprasController.addDetalleCompraOK(
                      idChatarraController.text,
                      idTicket,
                      cantidadController.text,
                      precioController.text,
                    );
                    _loadDetallesCompra(idTicket);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Añadir Detalle de Compra'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Detalles de Compra',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Cantidad')),
                    DataColumn(label: Text('Precio')),
                    DataColumn(label: Text('Subtotal')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows: detallesCompra.map((detalle) {
                    return DataRow(
                      cells: [
                        DataCell(Text(detalle['id_detallecompra'].toString())),
                        DataCell(Text(detalle['nombre'])),
                        DataCell(Text(detalle['cantidad'].toString())),
                        DataCell(Text(detalle['preciopagado'].toString())),
                        DataCell(Text(detalle['subtotal'].toString())),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _handleEditDetalle(detalle);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDeleteConfirmationDialog(
                                    detallesCompra.indexOf(detalle));
                              },
                            ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Lógica para imprimir o guardar la compra
                },
                child: const Text('Imprimir'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _getStoredJwtToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt') ?? '';
  }

  Future<void> _handleEditDetalle(Map<String, dynamic> detalle) async {
    final updatedDetalle = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditDetalleDialog(detalle: detalle),
    );

    if (updatedDetalle != null) {
      try {
        final String jwt = await _getStoredJwtToken();
        await _comprasController.updateDetalle(jwt, updatedDetalle);
        final idTicket = idTicketController.text;
        _loadDetallesCompra(idTicket);
      } catch (e) {
        print(e);
      }
    }
  }
}
