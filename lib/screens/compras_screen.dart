import 'package:flutter/material.dart';

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});

  @override
  _ComprasScreenState createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  final TextEditingController idVendedorController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  final List<Map<String, dynamic>> detallesCompra = [];

  void addDetalleCompra() {
    setState(() {
      detallesCompra.add({
        'id': detallesCompra.length + 1,
        'detalles':
            'Chatarra', // Puedes reemplazar esto con el valor seleccionado del dropdown
        'cantidad': cantidadController.text,
        'precio': precioController.text,
        'subtotal': (double.parse(precioController.text) *
                double.parse(cantidadController.text))
            .toString(),
      });
      cantidadController.clear();
      precioController.clear();
    });
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
                              controller: idVendedorController,
                              decoration: const InputDecoration(
                                  labelText: 'ID Vendedor'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: nombreController,
                              decoration:
                                  const InputDecoration(labelText: 'Nombre'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: telefonoController,
                              decoration:
                                  const InputDecoration(labelText: 'Teléfono'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: direccionController,
                              decoration:
                                  const InputDecoration(labelText: 'Dirección'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: TextField(
                                  controller: fechaController,
                                  decoration: const InputDecoration(
                                    labelText: 'Fecha',
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Lógica para añadir proveedor
                            },
                            child: const Text('Añadir'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Añadir Chatarras',
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
                            child: DropdownButtonFormField<String>(
                              items: const [
                                DropdownMenuItem(
                                    value: '1', child: Text('Chatarra 1')),
                                DropdownMenuItem(
                                    value: '2', child: Text('Chatarra 2')),
                              ],
                              onChanged: (value) {
                                // Lógica para manejar la selección
                              },
                              decoration:
                                  const InputDecoration(labelText: 'Chatarra'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: precioController,
                              decoration:
                                  const InputDecoration(labelText: 'Precio'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cantidadController,
                              decoration:
                                  const InputDecoration(labelText: 'Cantidad'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: addDetalleCompra,
                            child: const Text('Añadir'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Detalles de Compra',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Table(
                border: TableBorder.all(),
                children: [
                  const TableRow(
                    children: [
                      TableCell(
                          child: Padding(
                              padding: EdgeInsets.all(8.0), child: Text('ID'))),
                      TableCell(
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Detalles'))),
                      TableCell(
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Cantidad'))),
                      TableCell(
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Precio'))),
                      TableCell(
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Subtotal'))),
                      TableCell(
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Acciones'))),
                    ],
                  ),
                  ...detallesCompra.map(
                    (detalle) => TableRow(
                      children: [
                        TableCell(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(detalle['id'].toString()))),
                        TableCell(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(detalle['detalles']))),
                        TableCell(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(detalle['cantidad']))),
                        TableCell(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(detalle['precio']))),
                        TableCell(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(detalle['subtotal']))),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => showDeleteConfirmationDialog(
                                  detallesCompra.indexOf(detalle)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
