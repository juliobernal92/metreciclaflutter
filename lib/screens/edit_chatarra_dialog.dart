import 'package:flutter/material.dart';

class EditChatarraDialog extends StatefulWidget {
  final Map<String, dynamic> chatarra;

  const EditChatarraDialog({required this.chatarra, super.key});

  @override
  _EditChatarraDialogState createState() => _EditChatarraDialogState();
}

class _EditChatarraDialogState extends State<EditChatarraDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late double _precio;
  late int _id;

  @override
  void initState() {
    super.initState();
    _nombre = widget.chatarra['nombre'];
    _precio = widget.chatarra['precio'] != null
        ? (widget.chatarra['precio'] is int
            ? (widget.chatarra['precio'] as int).toDouble()
            : widget.chatarra['precio'])
        : 0.0; // Valor por defecto si es null
    _id = widget.chatarra['id_chatarra'] ?? 0; // Asignar 0 si el ID es null
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Chatarra'),
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
              initialValue: _precio.toString(),
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
        'id_chatarra': _id,
        'nombre': _nombre,
        'precio': _precio,
      });
    }
  }
}
