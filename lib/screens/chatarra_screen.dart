import 'package:flutter/material.dart';
import 'package:metrecicla_app/controllers/chatarras_controller.dart';
import 'package:metrecicla_app/screens/add_chatarra_dialog.dart';
import 'package:metrecicla_app/screens/edit_chatarra_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metrecicla_app/controllers/api_interceptor.dart';

class ChatarraScreen extends StatefulWidget {
  const ChatarraScreen({super.key});

  @override
  _ChatarraScreenState createState() => _ChatarraScreenState();
}

class _ChatarraScreenState extends State<ChatarraScreen> {
  late ChatarraController _chatarraController;
  List<Map<String, dynamic>> _chatarras = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chatarraController = ChatarraController(ApiInterceptor(context));
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String jwt = await _getStoredJwtToken();
      List<Map<String, dynamic>> chatarras =
          await _chatarraController.fetchChatarras();

      setState(() {
        _chatarras = chatarras;
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

  Future<void> _handleEditChatarra(Map<String, dynamic> chatarra) async {
    final updatedChatarra = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditChatarraDialog(chatarra: chatarra),
    );

    if (updatedChatarra != null) {
      try {
        final String jwt = await _getStoredJwtToken();
        await _chatarraController.updateChatarra(jwt, updatedChatarra);
        _fetchData();
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Chatarras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _handleAddChatarra,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Nombre')),
                  DataColumn(label: Text('Precio')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: _chatarras
                    .map((chatarra) => DataRow(
                          cells: [
                            DataCell(Text(chatarra['nombre'])),
                            DataCell(Text('${chatarra['precio']}')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _handleEditChatarra(chatarra),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _handleDeleteChatarra(chatarra),
                                ),
                              ],
                            )),
                          ],
                        ))
                    .toList(),
              ),
            ),
    );
  }

  Future<void> _handleAddChatarra() async {
    final newChatarra = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          const AddChatarraDialog(), // Asegúrate de pasar `chatarra` si es necesario
    );

    if (newChatarra != null) {
      try {
        final String jwt = await _getStoredJwtToken();
        await _chatarraController.addChatarra(jwt, newChatarra);
        _fetchData();
      } catch (e) {
        print('Error adding chatarra: $e');
      }
    }
  }

  Future<void> _handleDeleteChatarra(Map<String, dynamic> chatarra) async {
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
        final int idChatarra = chatarra['id_chatarra'];

        await _chatarraController.deleteChatarra(jwt, idChatarra);
        _fetchData();
      } catch (e) {
        print('Error deleting chatarra: $e');
      }
    }
  }
}
