import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metrecicla_app/controllers/api_interceptor.dart';
import 'package:metrecicla_app/controllers/compras_controller.dart';
import 'package:metrecicla_app/screens/edit_detalle_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
    _comprasController.nombreController = nombreController;
    _comprasController.telefonoController = telefonoController;
    _comprasController.direccionController = direccionController;
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

  void _loadDetallesCompra(String idTicket) async {
    try {
      List<Map<String, dynamic>> detalles =
          await _comprasController.fetchDetallesCompraPorTicket(idTicket);
      setState(() {
        detallesCompra = detalles;
      });
    } catch (error) {
      print('Error al cargar detalles de compra: $error');
      // Handle the error accordingly
    }
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
                    if (idTicket != null) {
                      idTicketController.text = idTicket;
                    }
                  } else {
                    idTicket = idTicketController.text;
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
                                _handleDeleteDetalle(detalle);
                              },
                            ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL: ${NumberFormat.currency(locale: 'es_ES', symbol: '').format(calcularTotal())}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: generarPdfSiCamposCargados,
                child: const Text('Imprimir'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double calcularTotal() {
    double total = 0.0;
    for (var detalle in detallesCompra) {
      total += detalle['subtotal'];
    }
    return total;
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

  //PDF
  void generarPdfSiCamposCargados() {
    // Validar campos requeridos
    if (fechaController.text.isEmpty ||
        nombreController.text.isEmpty ||
        detallesCompra.isEmpty) {
      Get.snackbar(
        'Error',
        'Todos los campos son requeridos para imprimir el ticket',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(
          Icons.error,
          color: Colors.white,
        ),
        snackPosition: SnackPosition.TOP,
      );
    } else {
      _generatePdf();
    }
  }

  void _generatePdf() async {
    final idTicket = idTicketController.text;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '------MET RECICLA------',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '---SUCURSAL LUQUE---',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('TELEFONO: 0984-749327'),
              pw.SizedBox(height: 10),
              pw.Text('FECHA: ${fechaController.text}'),
              pw.Text(
                  'CLIENTE: ${nombreController.text.isEmpty ? "SIN NOMBRE" : nombreController.text}'),
              pw.SizedBox(height: 10),
              pw.Text('----------------------------'),
              pw.Text('CANT  DESC  PREC  SUBT'),
              pw.Text('----------------------------'),
              ...detallesCompra.map((detalle) {
                return pw.Text(
                  '${detalle['cantidad']}  ${detalle['nombre']}  ${NumberFormat.currency(locale: 'es_ES', symbol: '').format(detalle['preciopagado'])}  ${NumberFormat.currency(locale: 'es_ES', symbol: '').format(detalle['subtotal'])}',
                );
              }),
              pw.Text('----------------------------'),
              pw.Text(
                'TOTAL:                ${NumberFormat.currency(locale: 'es_ES', symbol: '').format(calcularTotal())}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name: 'ticket_$idTicket.pdf',
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    limpiarTodosLosCampos();
  }

  void limpiarTodosLosCampos() {
    idTicketController.text = '';
    fechaController.text = '';
    nombreController.text = '';
    cantidadController.text = '';
    precioController.text = '';
    idChatarraController.text = '';
    idEmpleadoController.text = '';
    idProveedorController.text = '';
    direccionController.text = '';
    telefonoController.text = '';

    setState(() {
      // Clear the DataTable data source
      detallesCompra.clear();

      // Reset the ComboBox to its initial value
      _selectedChatarra = null;
    });
  }

//ELIMINAR

  Future<void> _handleDeleteDetalle(Map<String, dynamic> detalle) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de eliminar esta chatarra?'),
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
        final int idDetalle = detalle['id_detallecompra'];

        await _comprasController.deleteDetalle(jwt, idDetalle);
        final idTicket = idTicketController.text;
        _loadDetallesCompra(idTicket);
      } catch (e) {
        print('Error deleting detalle: $e');
      }
    }
  }
}
