import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:metrecicla_app/controllers/api_interceptor.dart';
import 'package:metrecicla_app/controllers/compras_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});

  @override
  _ComprasScreenState createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final TextEditingController idProveedorController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  String _idproveedor = '';
  String? _selectedChatarra;

  final List<Map<String, dynamic>> detallesCompra = [];
  late ComprasController _comprasController;

  final List<String> _chatarras = [
    'Chatarra 1',
    'Chatarra 2',
    'Chatarra 3',
    'Chatarra 4',
  ];

  @override
  void initState() {
    super.initState();
    // Configura la fecha actual al inicializar el estado
    final DateTime now = DateTime.now();
    fechaController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    _comprasController = ComprasController(ApiInterceptor(context));
    _comprasController.idProveedorController = idProveedorController;
  }

  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idprov = prefs.getString("id_proveedor");

    if (idprov != null && idprov.isNotEmpty) {
      idProveedorController.text = idprov;
      print("EL ID PROVEEDOR PASANDO: $idprov");
    }
  }

  void loadsavedataid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombre = prefs.getString("nombre");
    if (nombre != null) {
      print("EL NOMBRE RECUPERADO: $nombre");
      setState(() {
        nombreController.text = nombre;
      });
    }

    String? telefono = prefs.getString("telefono");
    if (telefono != null) {
      print("EL TELEFONO RECUPERADO: $telefono");
      setState(() {
        telefonoController.text = telefono;
      });
    }

    String? direccion = prefs.getString("direccion");
    if (direccion != null) {
      print("LA DIRECCIÓN RECUPERADA: $direccion");
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
              DropdownButtonFormField<String>(
                value: _selectedChatarra,
                decoration: const InputDecoration(labelText: 'Chatarra'),
                items: _chatarras.map((String chatarra) {
                  return DropdownMenuItem<String>(
                    value: chatarra,
                    child: Text(chatarra),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedChatarra = newValue!;
                  });
                },
              ),
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
                onPressed: () {
                  setState(() {
                    detallesCompra.add({
                      'id_chatarra': _selectedChatarra,
                      'precio': precioController.text,
                      'cantidad': cantidadController.text,
                    });
                  });
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
                    DataColumn(label: Text('Detalles')),
                    DataColumn(label: Text('Cantidad')),
                    DataColumn(label: Text('Precio')),
                    DataColumn(label: Text('Subtotal')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows: detallesCompra.map((detalle) {
                    return DataRow(
                      cells: [
                        DataCell(Text(detalle['id_chatarra'].toString())),
                        DataCell(Text(
                            'Detalles')), // Puedes ajustar esto según tu lógica
                        DataCell(Text(detalle['cantidad'])),
                        DataCell(Text(detalle['precio'])),
                        DataCell(Text((double.parse(detalle['precio']) *
                                double.parse(detalle['cantidad']))
                            .toString())),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {},
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
}
