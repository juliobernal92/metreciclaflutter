import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metrecicla_app/controllers/chatarras_controller.dart';

class ChatarraScreen extends StatefulWidget {
  const ChatarraScreen({Key? key}) : super(key: key);

  @override
  _ChatarraScreenState createState() => _ChatarraScreenState();
}

class _ChatarraScreenState extends State<ChatarraScreen> {
  final ChatarraController _chatarraController = ChatarraController();
  List<Map<String, dynamic>> _chatarras = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String jwt = await _getStoredJwtToken();
      List<Map<String, dynamic>> chatarras =
          await _chatarraController.fetchChatarras(jwt);

      setState(() {
        _chatarras = chatarras;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching chatarras: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getStoredJwtToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt') ?? '';
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
    // Implementar lógica para añadir chatarra
  }

  Future<void> _handleEditChatarra(Map<String, dynamic> chatarra) async {
    // Implementar lógica para editar chatarra
  }

  Future<void> _handleDeleteChatarra(Map<String, dynamic> chatarra) async {
    // Implementar lógica para eliminar chatarra
  }
}
