import 'package:flutter/material.dart';

class EditProveedorDialog extends StatefulWidget {
  final Map<String, dynamic> proveedor;

  const EditProveedorDialog({required this.proveedor, super.key});

  @override
  _EditProveedorDialogState createState() => _EditProveedorDialogState();
}

class _EditProveedorDialogState extends State<EditProveedorDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late String _direccion;
  late String _telefono;
  late int _id;

  @override
  void initState() {
    super.initState();
    _nombre = widget.proveedor['nombre'] ?? '';
    _direccion = widget.proveedor['direccion'] ?? '';
    _telefono = widget.proveedor['telefono'] ?? '';
    _id = widget.proveedor['id_proveedor'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Proveedor'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ID: $_id'), // Mostrar el ID en el diálogo
            TextFormField(
              initialValue: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
              onSaved: (value) {
                _nombre = value!;
              },
            ),
            TextFormField(
              initialValue: _direccion.toString(),
              decoration: const InputDecoration(labelText: 'Direccion'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una direccion';
                }
                return null;
              },
              onSaved: (value) {
                _direccion = value!;
              },
            ),
            TextFormField(
              initialValue: _telefono.toString(),
              decoration: const InputDecoration(labelText: 'Telefono'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un numero de telefono';
                }
                return null;
              },
              onSaved: (value) {
                _telefono = value!;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context).pop({
        'id_proveedor': _id,
        'nombre': _nombre,
        'direccion': _direccion,
        'telefono': _telefono
      });
    }
  }
}
