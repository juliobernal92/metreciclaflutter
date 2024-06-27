import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // Importa http correctamente
import 'package:metrecicla_app/controllers/login_controller.dart';
import 'package:metrecicla_app/screens/dashboard_screen.dart';
import 'package:metrecicla_app/screens/chatarra_screen.dart';
import 'package:metrecicla_app/screens/compras_screen.dart';
import 'package:metrecicla_app/screens/login_screen.dart';
import 'package:metrecicla_app/screens/proveedores_screen.dart';
import 'package:metrecicla_app/screens/empleados_screen.dart';
import 'package:metrecicla_app/controllers/api_interceptor.dart';

class CustomColors {
  static const Color primaryColor = Color(0xFF4CAF50); // Verde principal
  static const Color accentColor = Color(0xFF66BB6A); // Verde de acento
  static const Color textColor = Colors.black; // Color de texto principal
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    ChatarraScreen(),
    ComprasScreen(),
    ProveedoresScreen(),
    EmpleadosScreen(),
  ];

  // Cliente HTTP con interceptor
  late final http.Client _client;

  @override
  void initState() {
    super.initState();
    // Inicializa el cliente HTTP con el interceptor
    _client = http.Client();
  }

  void _onItemTapped(int index) {
    if (index == 5) {
      _showLogoutConfirmationDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Cerrar sesión?'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cerrar Sesión'),
              onPressed: () {
                _signOut();
              },
            ),
          ],
        );
      },
    );
  }

  void _signOut() {
    Get.find<LoginController>().signOut();
    Get.offAll(() => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Met Recicla'),
        backgroundColor: CustomColors.primaryColor,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_repair),
            label: 'Chatarras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Compras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Proveedores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Empleados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            label: 'Cerrar Sesión',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: CustomColors.accentColor,
        unselectedItemColor: CustomColors.textColor,
        backgroundColor: CustomColors.primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
