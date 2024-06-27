import 'package:flutter/material.dart';

class AddProveedorDialog extends StatefulWidget {
  final Map<String, dynamic>? proveedor; // Cambiado a opcional

  const AddProveedorDialog(
      {super.key, this.proveedor}); // Ajuste en el constructor

  @override
  _AddProveedorDialogState createState() => _AddProveedorDialogState();
}

class _AddProveedorDialogState extends State<AddProveedorDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late String _direccion;
  late String _telefono;

  @override
  void initState() {
    super.initState();
    _nombre = widget.proveedor?['nombre'] ?? '';
    _direccion = widget.proveedor?['direccion'] ?? '';
    _telefono = widget.proveedor?['telefono'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Proveedor'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              initialValue: _direccion,
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
              initialValue: _telefono,
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
      Navigator.of(context).pop(
          {'nombre': _nombre, 'direccion': _direccion, 'telefono': _telefono});
    }
  }
}
