// Dialog to Edit Detail (EditDetalleDialog)
import 'package:flutter/material.dart';

class EditDetalleDialog extends StatefulWidget {
  final Map<String, dynamic> detalle;

  EditDetalleDialog({required this.detalle});

  @override
  _EditDetalleDialogState createState() => _EditDetalleDialogState();
}

class _EditDetalleDialogState extends State<EditDetalleDialog> {
  late TextEditingController cantidadController;
  late TextEditingController precioController;
  late TextEditingController idController;

  @override
  void initState() {
    super.initState();
    cantidadController =
        TextEditingController(text: widget.detalle['cantidad'].toString());
    precioController =
        TextEditingController(text: widget.detalle['preciopagado'].toString());
    idController = TextEditingController(
        text: widget.detalle['id_detallecompra'].toString());
  }

  @override
  void dispose() {
    cantidadController.dispose();
    precioController.dispose();
    idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Detalle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: idController,
            decoration: InputDecoration(labelText: 'ID Detalle'),
            enabled: false,
          ),
          TextField(
            controller: precioController,
            decoration: InputDecoration(labelText: 'Precio'),
          ),
          TextField(
            controller: cantidadController,
            decoration: InputDecoration(labelText: 'Cantidad'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Guardar'),
          onPressed: () {
            Navigator.of(context).pop({
              'id_detallecompra': idController.text,
              'nuevoPrecio': precioController.text,
              'cantidad': cantidadController.text,
            });
          },
        ),
      ],
    );
  }
}
