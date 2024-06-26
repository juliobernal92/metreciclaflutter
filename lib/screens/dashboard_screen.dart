import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: DashboardScreen(),
  ));
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _nombres = 'No se guardó el nombre';

  @override
  void initState() {
    super.initState();
    _loadSavedData(); // Cargar datos al inicializar la pantalla
  }

  // Función para cargar datos desde SharedPreferences
  Future<void> _loadSavedData() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _nombres = prefs.getString('nombres') ?? 'No se guardó el nombre';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: Text(
          'Bienvenido $_nombres',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
