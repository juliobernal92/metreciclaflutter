import 'package:flutter/material.dart';

class AddChatarraDialog extends StatefulWidget {
  final Map<String, dynamic>? chatarra; // Cambiado a opcional

  const AddChatarraDialog(
      {super.key, this.chatarra}); // Ajuste en el constructor

  @override
  _AddChatarraDialogState createState() => _AddChatarraDialogState();
}

class _AddChatarraDialogState extends State<AddChatarraDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late double _precio;

  @override
  void initState() {
    super.initState();
    _nombre = widget.chatarra?['nombre'] ??
        ''; // Inicialización con valor existente si se proporciona
    _precio = widget.chatarra?['precio'] ??
        0.0; // Inicialización con valor existente si se proporciona
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Chatarra'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue:
                  _nombre, // Establecer valor inicial si está presente
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
              initialValue: _precio
                  .toString(), // Establecer valor inicial si está presente
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un precio';
                }
                if (double.tryParse(value) == null) {
                  return 'Por favor ingresa un número válido';
                }
                return null;
              },
              onSaved: (value) {
                _precio = double.parse(value!);
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
        'nombre': _nombre,
        'precio': _precio,
      });
    }
  }
}
