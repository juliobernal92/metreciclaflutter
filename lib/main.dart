import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metrecicla_app/screens/login_screen.dart';
import 'package:metrecicla_app/controllers/login_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(LoginController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Met Recicla',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoginScreen(),
    );
  }
}
